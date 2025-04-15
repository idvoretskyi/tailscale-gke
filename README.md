# Tailscale GKE Exit Node

A cost-effective Terraform configuration for deploying a Tailscale exit node on Google Kubernetes Engine (GKE). This setup allows you to route your traffic through a Google Cloud exit node, giving you the ability to use a public IP address from Google Cloud.

![Tailscale with GKE](https://tailscale.com/blog/img/2022-02-kubernetes-operator/header-tailscale-kubernetes.png)

## Overview

This Terraform project automates the deployment of:
- A cost-optimized GKE cluster on Google Cloud
- A Tailscale exit node running on the GKE cluster

With this setup, you can:
- Connect to your GKE cluster from your laptop or other devices through Tailscale
- Use the GKE cluster as an exit node for your internet traffic
- Benefit from Google Cloud's global network for internet connectivity

## Features

### Cost Optimization Features
- **Zonal cluster** instead of regional to reduce control plane costs
- **Spot VMs** (preemptible instances) for up to 90% cost reduction
- **Node autoscaling** to automatically adjust to resource needs
- **Optimized machine types** (e2-small by default)
- **Vertical Pod Autoscaling (VPA)** for efficient resource allocation
- **Off-hours maintenance** to minimize disruption

### Tailscale Features
- **Exit node capability** allowing you to route traffic through Google Cloud
- **Persistent configuration** using Kubernetes volumes
- **Automatic reconnection** in case of node restarts/replacements
- **Secure authentication** using Tailscale auth keys

## Prerequisites

- Google Cloud Platform account with billing enabled
- Tailscale account and auth key with sufficient permissions
- [Google Cloud CLI](https://cloud.google.com/sdk/docs/install) (`gcloud`)
- [Terraform](https://developer.hashicorp.com/terraform/downloads) (v1.0.0 or newer)

## Installation and Setup

### 1. Clone this repository
```bash
git clone https://github.com/idvoretskyi/tailscale-gke.git
cd tailscale-gke
```

### 2. Create your variables file
```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit the `terraform.tfvars` file to add your GCP project ID and Tailscale auth key:
```hcl
project_id = "your-gcp-project-id"
region = "us-central1"
zone = "us-central1-a"
tailscale_auth_key = "tskey-auth-YOUR_ACTUAL_AUTH_KEY"
```

### 3. Initialize Terraform
```bash
terraform init
```

### 4. Apply the configuration
```bash
terraform plan
terraform apply
```

## Connecting to Your Exit Node

After deploying the infrastructure:

1. In the [Tailscale admin console](https://login.tailscale.com/admin/machines), you'll see a new machine appear
2. Enable the exit node capability in your Tailscale admin console:
   - Navigate to **DNS** > **Exit Nodes**
   - Toggle on the option for your GKE node
3. On your client devices:
   - Open the Tailscale client
   - Click on **Settings** > **Use Exit Node** > Select your GKE exit node

## Configuration Options

| Variable | Description | Default | 
|----------|-------------|---------|
| `project_id` | Your GCP project ID | (Required) |
| `region` | GCP region for deployment | `us-central1` |
| `zone` | Specific zone for the GKE cluster | `us-central1-a` |
| `cluster_name` | Name of the GKE cluster | `tailscale-gke-cluster` |
| `machine_type` | VM type for the GKE nodes | `e2-small` |
| `min_node_count` | Minimum nodes for autoscaling | `1` |
| `max_node_count` | Maximum nodes for autoscaling | `2` |
| `use_preemptible_nodes` | Whether to use Spot VMs | `true` |
| `tailscale_auth_key` | Your Tailscale auth key | (Required) |

## Cost Considerations

This setup is designed to be cost-effective:

- **Spot VM pricing**: 60-91% discount from standard pricing
- **Zonal deployment**: ~67% cheaper than regional clusters
- **e2-small instances**: Minimal but sufficient resources
- **Autoscaling**: Only pay for the capacity you need

Estimated monthly cost: **~$20-40/month** (varies by region, usage, and current pricing)

## Security Notes

1. The Tailscale auth key is stored as a Kubernetes secret
2. The Tailscale container runs in privileged mode (required for networking)
3. Best practice: rotate your Tailscale auth keys periodically

## Limitations of Using Spot VMs

- VMs may be terminated with little notice (typically 30 seconds)
- Maximum runtime of 24 hours before forced termination
- Brief service interruptions during node replacements

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- [Tailscale](https://tailscale.com/) for their excellent VPN service
- [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine) for the reliable container orchestration platform

---

*Last updated: April 2025*