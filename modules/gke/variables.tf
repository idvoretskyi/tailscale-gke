variable "project_id" {
  description = "The GCP project ID"
}

variable "region" {
  description = "The GCP region to deploy resources"
}

variable "zone" {
  description = "The GCP zone to deploy resources (for zonal clusters, which are more cost-effective)"
  default     = ""
}

variable "cluster_name" {
  description = "The name of the GKE cluster"
}

variable "network" {
  description = "The VPC network to use for the cluster"
}

variable "subnetwork" {
  description = "The subnetwork to use for the cluster"
}

variable "node_count" {
  description = "The number of nodes in the GKE node pool (used if autoscaling is disabled)"
  default     = 1
}

variable "min_node_count" {
  description = "Minimum number of nodes for autoscaling"
  default     = 1
}

variable "max_node_count" {
  description = "Maximum number of nodes for autoscaling"
  default     = 3
}

variable "machine_type" {
  description = "The machine type for GKE nodes"
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