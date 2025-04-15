resource "google_container_cluster" "primary" {
  name     = var.cluster_name
  location = var.zone != "" ? var.zone : var.region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1

  network    = var.network
  subnetwork = var.subnetwork

  # Enable cost-effective cluster settings
  release_channel {
    channel = "REGULAR"
  }

  # Enable network policy for better security
  network_policy {
    enabled = true
    provider = "CALICO"
  }

  # Enable shielded nodes for improved security
  node_config {
    shielded_instance_config {
      enable_secure_boot = true
    }
  }

  # Enable private cluster configuration if specified
  dynamic "private_cluster_config" {
    for_each = var.private_cluster ? [1] : []
    content {
      enable_private_nodes    = true
      enable_private_endpoint = false
      master_ipv4_cidr_block  = var.master_ipv4_cidr_block
    }
  }

  # Enable Workload Identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }

  # Enable resources usage efficiency
  vertical_pod_autoscaling {
    enabled = true
  }

  # Cost optimization with maintenance window during off-hours
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00" # 3 AM, typically low traffic
    }
  }
}

resource "google_container_node_pool" "primary_nodes" {
  name     = "${var.cluster_name}-node-pool"
  location = var.zone != "" ? var.zone : var.region
  cluster  = google_container_cluster.primary.name

  # Use autoscaling instead of fixed node count for cost optimization
  autoscaling {
    min_node_count = var.min_node_count
    max_node_count = var.max_node_count
  }

  # Enable automatic repairs and upgrades during low-usage hours
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  # Use Spot VMs (preemptible) for cost savings
  node_config {
    spot = var.use_preemptible_nodes

    oauth_scopes = [
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/cloud-platform"
    ]

    labels = {
      env         = var.project_id
      preemptible = var.use_preemptible_nodes ? "true" : "false"
    }

    machine_type = var.machine_type
    tags         = ["gke-node", "${var.cluster_name}-gke-node"]
    metadata = {
      disable-legacy-endpoints = "true"
    }

    # Enable Workload Identity on the node pool
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Enable shielded nodes for better security
    shielded_instance_config {
      enable_secure_boot = true
    }

    # Add resource usage limits to prevent overprovisioning
    resource_labels = {
      "managed-by"  = "terraform"
      "environment" = "cost-optimized"
    }
  }

  # Set a specific timeframe for the node pool to be active
  # Lower the timeouts to accelerate node operations
  timeouts {
    create = "30m"
    update = "20m"
    delete = "20m"
  }
}