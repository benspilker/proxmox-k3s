#!/bin/bash

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
echo "ubuntuprox:<your-new-user-password-here>" | chpasswd

# Step 1A.4 switch user to ubuntuprox
su - ubuntuprox