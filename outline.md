Proxmox K3s Setup Guide
├── Step 0: Optional Initial Proxmox Setup
│   ├── Create LVM
│   ├── Backup Proxmox Configuration
│   ├── Add LVM Storage
│   └── Upgrade Proxmox
├── Step 1: Prepare Proxmox Instance for K3s
│   ├── Create a New User
│   └── Set Up SSH
├── Step 2: Prepare Proxmox for K3s Cluster
│   ├── Create VM Template
│   ├── Create VMs for K3s Cluster
│   └── Copy SSH Keys
├── Step 3: Installing K3s on Nodes
│   ├── Define Cluster Variables
│   ├── Prepare Admin Machine
│   ├── Bootstrap First K3s Node
│   ├── Install Kube-VIP for High Availability
│   ├── Join Additional Nodes
│   └── Install MetalLB
├── Step 4: Install Rancher UI and Tools
│   ├── Install Helm
│   ├── Add Rancher Helm Repo
│   ├── Install Cert Manager
│   ├── Install Rancher
│   └── Install Longhorn and Traefik
├── Step 5: Install Nextcloud Instance
│   ├── Install Nextcloud
│   ├── Create Self-Signed Certificate
│   ├── Define Ingress
│   └── Resolve Domain
└── Step 6: Persistent Volume Storage for Nextcloud
    ├── Delete Current Nextcloud Deployment
    ├── Create Persistent Volume Claims
    ├── Copy Configuration to Persistent Volume
    ├── Deploy Nextcloud with Persistent Storage
    └── Set Permissions
