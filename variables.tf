variable "project_id" {
  description = "The GCP project ID"
  type        = string
}

variable "region" {
  description = "The GCP region to deploy resources"
  type        = string
  default     = "us-central1"
}

variable "zone" {
  description = "The GCP zone to deploy resources (for zonal clusters, which are more cost-effective)"
  type        = string
  default     = "us-central1-a" # Specifying a zone makes the cluster zonal instead of regional, reducing costs
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
  type        = string
  default     = "tailscale-gke-cluster"
}

variable "network" {
  description = "The VPC network to use for the cluster"
  type        = string
  default     = "default"
}

variable "subnetwork" {
  description = "The subnetwork to use for the cluster"
  type        = string
  default     = "default"
}

variable "node_count" {
  description = "The number of nodes in the GKE node pool (used if autoscaling is disabled)"
  type        = number
  default     = 1
}

variable "min_node_count" {
  description = "Minimum number of nodes for autoscaling"
  type        = number
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes for autoscaling"
  type        = number
  default     = 2
}

variable "machine_type" {
  description = "The machine type for GKE nodes"
  type        = string
  default     = "e2-small" # Using e2-small instead of e2-standard-2 for cost savings
}

variable "use_preemptible_nodes" {
  description = "Whether to use preemptible/spot instances for the node pool (significantly reduces cost)"
  type        = bool
  default     = true
}

variable "private_cluster" {
  description = "Whether to enable private cluster configuration"
  type        = bool
  default     = false
}

variable "master_ipv4_cidr_block" {
  description = "The IP range for the master network (required when private_cluster is true)"
  type        = string
  default     = "172.16.0.0/28"
}

variable "tailscale_auth_key" {
  description = "Tailscale authentication key"
  type        = string
  sensitive   = true
}