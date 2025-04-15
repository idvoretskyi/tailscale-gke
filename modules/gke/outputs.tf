output "cluster_name" {
  description = "The name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "endpoint" {
  description = "The IP address of the GKE cluster"
  value       = google_container_cluster.primary.endpoint
}

output "ca_certificate" {
  description = "The cluster CA certificate (base64 encoded)"
  value       = google_container_cluster.primary.master_auth.0.cluster_ca_certificate
  sensitive   = true
}

output "cluster_id" {
  description = "The ID of the GKE cluster"
  value       = google_container_cluster.primary.id
}

output "cluster_self_link" {
  description = "The self-link of the GKE cluster"
  value       = google_container_cluster.primary.self_link
}

output "location" {
  description = "The location of the GKE cluster"
  value       = google_container_cluster.primary.location
}