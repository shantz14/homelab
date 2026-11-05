# Proxmox and k3s personal infrastructure.

Terraform, Ansible, Flux, Prometheus

## Overview
**Terraform** creates 2 vms on a desktop machine running **PVE** (Proxmox virtual environment).
Together with a Raspberry Pi 5 running Raspbian (Debian), it's a 3 node **k8s** cluster.
**Ansible** configures the 3 machines, including installing and configuring k3s.
**K3s** runs the cluster. 1 server node (a pve vm) and 2 worker nodes (the pi5 and a vm).

## Networking
The lab sits on its own subnet, behind a GL.iNet Beryl AX in.

- **Ingress:** all HTTP goes through **Traefik**, which routes by hostname.
- **Public (`*.isaacschwarz.dev`):** a **Cloudflare Tunnel** (2 `cloudflared` replicas in the cluster) forwards traffic to Traefik.
- Ingress hosts on `lab.home` are private; one on `isaacschwarz.dev` are public.
