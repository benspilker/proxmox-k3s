#!/bin/bash

# Script Part 2B, prep Proxmox instance for K3s cluster with VM creation #

# Optional, define credentials that were made in script step 1A.3, otherwise you'll have to manually enter the password for ubuntuprox
# Re-enter that password here
# PASSWORD=<your-new-password-from-step-1A.3>

# NOTE YOU NEED TO SET IPs and gateway accordingly for all VMs
# Otherwise make them DHCP and make reservations on DHCP server

# Step 2B.0 Define local gateway and VM IP's

ROUTER_GATEWAY="192.168.100.253"

ADMIN_VM_CIDR="192.168.100.6/24"

TEST_K3S_01_CIDR="192.168.100.76/24"
TEST_K3S_02_CIDR="192.168.100.92/24"
TEST_K3S_03_CIDR="192.168.100.93/24"

TEST_K3S_04_CIDR="192.168.100.94/24"
TEST_K3S_05_CIDR="192.168.100.95/24"

TEST_LONGHORN01_CIDR="192.168.100.3/24"
TEST_LONGHORN02_CIDR="192.168.100.4/24"
TEST_LONGHORN03_CIDR="192.168.100.5/24"

# Function and Variables called create_vm

# Step 2B.1 Function to create and configure a VM

create_vm() {
    local vm_id=$1
    local vm_name=$2
    local memory=$3
    local cores=$4
    local ip=$5
    local resize_disk=$6
    local extra_configs=$7

    sudo qm clone 5000 $vm_id --name $vm_name --full
    sudo qm set $vm_id --memory $memory --cores $cores --ipconfig0 ip=$ip
    [ -n "$extra_configs" ] && eval "$extra_configs"
}

# Define storage type for where to put larger VM disks (204, 205, 211-213)
# I typically have a volume I create for thick provisioned VMs called LVM-Thick

# Check if the LVM-Thick volume exists, otherwise use local-lvm
if sudo vgs | grep -q "LVM-Thick"; then
    storage="LVM-Thick"
else
    storage="local-lvm"
fi


# Creating individual VMs for the cluster

# Step 2B.2, VM 200 is admin VM where we'll run scripts to configure k3s
create_vm 200 "ubuntu-admin-vm" 2048 2 "$ADMIN_VM_CIDR,gw=$ROUTER_GATEWAY"


# Step 2B.3, VM's 201-203 will be K3S controllers
create_vm 201 "test-k3s-01" 4096 2 "$TEST_K3S_01_CIDR,gw=$ROUTER_GATEWAY"
create_vm 202 "test-k3s-02" 4096 2 "$TEST_K3S_02_CIDR,gw=$ROUTER_GATEWAY"
create_vm 203 "test-k3s-03" 4096 2 "$TEST_K3S_03_CIDR,gw=$ROUTER_GATEWAY"


# Step 2B.4, VM's 204 and 205 will be workload VMs
create_vm 204 "test-k3s-04" 6144 4 "$TEST_K3S_04_CIDR,gw=$ROUTER_GATEWAY"
sudo qm move_disk 204 scsi0 $storage
sudo lvremove -y /dev/pve/vm-204-disk-0
sudo sed -i '/unused0/d' /etc/pve/qemu-server/204.conf
sudo qm resize 204 scsi0 +22G
sudo qm set 204 --scsi0 $storage:vm-204-disk-0,cache=writethrough

create_vm 205 "test-k3s-05" 6144 4 "$TEST_K3S_05_CIDR,gw=$ROUTER_GATEWAY"
sudo qm move_disk 205 scsi0 $storage
sudo lvremove -y /dev/pve/vm-205-disk-0
sudo sed -i '/unused0/d' /etc/pve/qemu-server/205.conf
sudo qm resize 205 scsi0 +22G
sudo qm set 205 --scsi0 $storage:vm-205-disk-0,cache=writethrough


# Step 2B.5, VM's 211-213 will be storage workload VMs
create_vm 211 "test-longhorn01" 4096 2 "$TEST_LONGHORN01_CIDR,gw=$ROUTER_GATEWAY"
sudo qm move_disk 211 scsi0 $storage
sudo lvremove -y /dev/pve/vm-211-disk-0
sudo sed -i '/unused0/d' /etc/pve/qemu-server/211.conf
sudo qm resize 211 scsi0 +22G
sudo qm set 211 --scsi0 $storage:vm-211-disk-0,cache=writethrough

create_vm 212 "test-longhorn02" 4096 2 "$TEST_LONGHORN02_CIDR,gw=$ROUTER_GATEWAY"
sudo qm move_disk 212 scsi0 $storage
sudo lvremove -y /dev/pve/vm-212-disk-0
sudo sed -i '/unused0/d' /etc/pve/qemu-server/212.conf
sudo qm resize 212 scsi0 +22G
sudo qm set 212 --scsi0 $storage:vm-212-disk-0,cache=writethrough

create_vm 213 "test-longhorn03" 4096 2 "$TEST_LONGHORN03_CIDR,gw=$ROUTER_GATEWAY"
sudo qm move_disk 213 scsi0 $storage
sudo lvremove -y /dev/pve/vm-213-disk-0
sudo sed -i '/unused0/d' /etc/pve/qemu-server/213.conf
sudo qm resize 213 scsi0 +22G
sudo qm set 213 --scsi0 $storage:vm-213-disk-0,cache=writethrough

# Step 2B.6, Start all the VMs sequentially after creation

for vm_id in 200 201 202 203 204 205 211 212 213; do
    sudo qm start $vm_id
done


# Commented out, but for reference, a step to delete all script created VMs if needed
#  for vm_id in 200 201 202 203 204 205 211 212 213; do
#     sudo qm destroy $vm_id
# done