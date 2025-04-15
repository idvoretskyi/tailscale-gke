resource "kubernetes_namespace" "tailscale" {
  metadata {
    name = "tailscale"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/name"       = "tailscale"
    }
  }
}

resource "kubernetes_secret" "tailscale_auth" {
  metadata {
    name      = "tailscale-auth"
    namespace = kubernetes_namespace.tailscale.metadata[0].name
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/name"       = "tailscale"
    }
  }

  data = {
    TS_AUTH_KEY = var.auth_key
  }

  type = "Opaque"
}

resource "kubernetes_deployment" "tailscale" {
  metadata {
    name      = "tailscale"
    namespace = kubernetes_namespace.tailscale.metadata[0].name
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/name"       = "tailscale"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "tailscale"
      }
    }

    strategy {
      type = "Recreate"  # Ensure clean state when updating
    }

    template {
      metadata {
        labels = {
          app = "tailscale"
        }
      }

      spec {
        container {
          image = "tailscale/tailscale:stable"  # Use 'stable' instead of 'latest' for production
          name  = "tailscale"

          env {
            name = "TS_AUTH_KEY"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.tailscale_auth.metadata[0].name
                key  = "TS_AUTH_KEY"
              }
            }
          }

          env {
            name  = "TS_STATE_DIR"
            value = "/var/lib/tailscale"
          }

          # Set Tailscale as an exit node
          env {
            name  = "TS_EXTRA_ARGS"
            value = "--advertise-exit-node"
          }

          # Add hostname to make it identifiable in Tailscale admin console
          env {
            name  = "TS_HOSTNAME"
            value = "gke-exit-node"
          }

          # Enable Tailscale to use IP forwarding
          security_context {
            privileged = true
            capabilities {
              add = ["NET_ADMIN", "SYS_ADMIN"]
            }
          }

          # Add resource limits to avoid resource contention
          resources {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }

          volume_mount {
            mount_path = "/var/lib/tailscale"
            name       = "tailscale-state"
          }

          # Add livenessProbe to ensure Tailscale is running properly
          liveness_probe {
            exec {
              command = ["tailscale", "status"]
            }
            initial_delay_seconds = 30
            period_seconds        = 60
            failure_threshold     = 3
            timeout_seconds       = 10
          }

          # Add readinessProbe to ensure Tailscale is fully operational
          readiness_probe {
            exec {
              command = ["tailscale", "status"]
            }
            initial_delay_seconds = 5
            period_seconds        = 10
          }
        }

        # Add toleration for preemptible nodes to ensure Tailscale can run on preemptible nodes
        toleration {
          key    = "cloud.google.com/gke-preemptible"
          operator = "Equal"
          value  = "true"
          effect = "NoSchedule"
        }

        volume {
          name = "tailscale-state"
          empty_dir {}
        }

        # Enable IP forwarding in the pod
        host_network = true
      }
    }
  }
}