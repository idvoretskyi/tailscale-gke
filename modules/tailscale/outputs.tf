output "tailscale_namespace" {
  description = "The Kubernetes namespace where Tailscale is deployed"
  value       = kubernetes_namespace.tailscale.metadata[0].name
}

output "tailscale_deployment" {
  description = "The name of the Tailscale deployment"
  value       = kubernetes_deployment.tailscale.metadata[0].name
}