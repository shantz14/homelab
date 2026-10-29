provider "proxmox" {
  endpoint = "https://192.168.8.10:8006"
  insecure = true

  ssh {
    agent    = true
    username = "root"
  }
}
