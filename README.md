# Proxmox K3s Setup Guide

This guide outlines the steps to configure a Proxmox server for running a K3s Kubernetes cluster. It covers setting up Proxmox, preparing VMs, installing K3s, deploying Rancher, Installation of Nextcloud, and setting up Nextcloud with persistent storage.

Here’s a visual representation of how K3s works:

<img src="https://k3s.io/img/how-it-works-k3s-revised.svg" width="400" />

---

## Table of Contents
1. [Proxmox K3s Setup Guide](#proxmox-k3s-setup-guide)
2. [Step 0: Optional Initial Proxmox Setup](#step-0-optional-initial-proxmox-setup)
3. [Step 1: Prepare Proxmox Instance for K3s](#step-1-prepare-proxmox-instance-for-k3s)
4. [Step 2: Prepare Proxmox for K3s Cluster](#step-2-prepare-proxmox-for-k3s-cluster)
5. [Step 3: Installing K3s on Nodes](#step-3-installing-k3s-on-nodes)
6. [Step 4: Install Rancher UI and Tools](#step-4-install-rancher-ui-and-tools)
7. [Step 5: Install Nextcloud Instance](#step-5-install-nextcloud-instance)
8. [Step 6: Persistent Volume Storage for Nextcloud](#step-6-persistent-volume-storage-for-nextcloud)


---

## Step 0: Optional Initial Proxmox Setup

This step is optional and assumes Proxmox is already installed. It involves setting up LVM for storage management and upgrading Proxmox.

1. **Create LVM**: Set up a partition on `/dev/sda` and create a volume group `LVM-Thick`.
2. **Backup Proxmox Configuration**: Back up the Proxmox storage configuration to `/etc/pve/storage.cfg.bak`.
3. **Add LVM Storage**: Modify `/etc/pve/storage.cfg` to include the new LVM storage.
4. **Upgrade Proxmox**: Update Proxmox to the latest version.

---

## Step 1: Prepare Proxmox Instance for K3s

1. **Create a New User**: Add a `ubuntuprox` user with `sudo` privileges.
2. **Set Up SSH**: Generate SSH keys for `ubuntuprox` and copy them to the admin VM for access.

---

## Step 2: Prepare Proxmox for K3s Cluster

1. **Create VM Template**: Create an Ubuntu-based VM template with necessary resources (e.g., 4GB RAM, 2 CPU cores, SSH key setup).
2. **Create VMs for K3s Cluster**: Create multiple VMs to serve as K3s nodes.
3. **Copy SSH Keys**: Ensure SSH keys are copied to all VMs for secure communication.

---

## Step 3: Installing K3s on Nodes

1. **Define Cluster Variables**: Set up the necessary variables, such as K3s and Kube-VIP versions, and define node IPs.
2. **Prepare Admin Machine**: Ensure SSH keys are configured and required tools (`k3sup`, `kubectl`) are installed.
3. **Bootstrap First K3s Node**: Use `k3sup` to install K3s on the first master node.
4. **Install Kube-VIP for High Availability**: Deploy Kube-VIP for high availability and configure a virtual IP (VIP) for the K3s API.
5. **Join Additional Nodes**: Add more master and worker nodes to the cluster as needed.
6. **Install MetalLB**: Set up MetalLB to manage LoadBalancer services for K3s.

---

## Step 4: Install Rancher UI and Tools

1. **Install Helm**: Ensure Helm is installed on the admin VM.
2. **Add Rancher Helm Repo**: Add the Rancher Helm chart repository.
3. **Install Cert Manager**: Set up Cert Manager to handle SSL/TLS certificates.
4. **Install Rancher**: Install Rancher using Helm and expose it via a LoadBalancer for UI access.
5. **Install Longhorn and Traefik**: Deploy Longhorn for persistent storage and Traefik for ingress management.

---

## Step 5: Install Nextcloud Instance

1. **Install Nextcloud**: Deploy Nextcloud using Helm in its own Kubernetes namespace.
2. **Create Self-Signed Certificate**: Generate a self-signed certificate for HTTPS access to Nextcloud.
3. **Define Ingress**: Create and apply an Ingress resource to expose Nextcloud via HTTPS.
4. **Resolve Domain**: Ensure the Nextcloud domain is correctly resolved to the Ingress IP.

---

## Step 6: Persistent Volume Storage for Nextcloud

1. **Delete Current Nextcloud Deployment**: Remove any existing Nextcloud deployment to prepare for persistent storage.
2. **Create Persistent Volume Claims**: Define and apply Persistent Volume Claims for Nextcloud's data.
3. **Copy Configuration to Persistent Volume**: Transfer the Nextcloud configuration to the persistent storage.
4. **Deploy Nextcloud with Persistent Storage**: Apply the new Nextcloud deployment configuration with persistent storage.
5. **Set Permissions**: Adjust the permissions on Nextcloud's configuration and data folders.

---

This completes the setup for Nextcloud with persistent storage and a fully functioning K3s cluster on Proxmox.
