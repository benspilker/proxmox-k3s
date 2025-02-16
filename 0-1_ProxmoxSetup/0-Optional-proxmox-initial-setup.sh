#!/bin/bash

# STEP 0 is OPTIONAL Initial Proxmox Setup Script to make a thick lvm and upgrade proxmox to the latest 8.x version

# Open the shell, copy and paste this into the shell
# NOTE ONLY RUN THIS IF YOU FIRST INSTALLED PROXMOX AND LEFT UNALLOCATED SPACE

# Step 0.1 (Assuming Proxmox v8.x was already installed)
# create usable thick provisioned proxmox logical volume (LVM)

# The disk to work with (e.g., /dev/sda)
DISK="/dev/sda"
PARTITION="${DISK}4"
VOLUME_GROUP="LVM-Thick"  # Volume Group name
LV_NAME="lv"             # Logical Volume name

# Step 0.1A: Create a new partition (using unallocated space) on the disk
echo -e "n\n\n\n\n\nw" | fdisk $DISK

# Step 0.1B: Change the partition type to Linux LVM (type 43)
echo -e "t\n4\n43\nw" | fdisk $DISK

if fdisk -l /dev/sda | grep -q "^/dev/sda4.*Linux"; then
    echo "Partition /dev/sda4 exists and is of type Linux LVM. Proceeding with further commands."
    # Step 0.1C: Create a Volume Group (VG) with the new partition
    vgcreate $VOLUME_GROUP $PARTITION

    # Step 0.1D: Verify the volume group creation
    vgs

    # Step 0.1E: Backup the storage.cfg before making changes
    STORAGE_CFG="/etc/pve/storage.cfg"
    cp $STORAGE_CFG $STORAGE_CFG.bak

    # Step 0.1F: Add the LVM storage configuration entry to the storage.cfg
    echo -e "\nlvm: $VOLUME_GROUP\n    vgname $VOLUME_GROUP\n    content images,rootdir\n    disable 0" >> $STORAGE_CFG

    # Step 0.1G: Check the storage.cfg file to ensure proper formatting
    cat $STORAGE_CFG | grep -A 5 $VOLUME_GROUP

    # Step 0.1H: Reload the storage configuration to ensure Proxmox picks it up
    pvesh get /nodes/$(hostname)/storage

    # Step 0.1I: Confirm if LVM is now listed as a storage option
    pvesh get /nodes/$(hostname)/storage | grep $VOLUME_GROUP

else
    echo "Partition /dev/sda4 does not exist or is not of type Linux LVM. Exiting."
    exit 1
fi


# Step 0.2, Additionally we can add the non-subscription repository and update

# New content to write to the file
cat <<EOF > /etc/apt/sources.list
deb http://ftp.us.debian.org/debian bookworm main contrib

deb http://ftp.us.debian.org/debian bookworm-updates main contrib

deb http://download.proxmox.com/debian/pve bookworm pve-no-subscription

# security updates
deb http://security.debian.org bookworm-security main contrib
EOF

echo "File /etc/apt/sources.list has been updated with the new content."

apt-get update
apt-get dist-upgrade -y

 echo "Update command was ran and likely updates were applied. Please reboot host..."
 echo "Script run complete. Host can also be rebooted by simply typing reboot"

# Script to prep Proxmox instance for K3s cluster

# install sudo as root first
apt install sudo -y

# For better security, create a separate Linux user instead of using root, PASSWORD DEFINED ON STEP 1A.3
# You will also need to define a separate password for your ubuntu VMs on steps in Script 2.

# Note this is a user to the OS host running Proxmox, not the Proxmox UI, therefore you won't see this as an added user in the Proxmox UI

# Step 1A.1 Create the user with the default home directory location and bash shell.
useradd -m -s /bin/bash ubuntuprox

# Step 1A.2 Add them to the sudo group
usermod -aG sudo ubuntuprox

# Step 1A.3 Set a password for new user
echo "ubuntuprox:<your-new-password-from-step-1A.3>" | chpasswd

# Step 1A.4 switch user to ubuntuprox
su - ubuntuprox

#!/bin/bash

# Step 1B.1 switch user to ubuntuprox
su - ubuntuprox

# Step 1B.2 Create ssh key for the new user
ssh-keygen -t rsa -f ~/.ssh/id_rsa -N ""

# change to the .ssh directory
cd ./.ssh

# Make a note of these ssh keys!
cat id_rsa

# copy this to your own computer. We will use these later

cat id_rsa.pub

# copy this to your own computer. We will use these later