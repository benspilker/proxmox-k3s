#!/bin/bash

# Step 2C.1 switch user to ubuntuprox (if you haven't already)
su - ubuntuprox

# Step 2C.2 We need to copy our private ( id_rsa ) and public ( id_rsa.pub ) keys to the home directory of the admin vm amd set permissions

# Note the IP of the admin machine
ADMIN_VM_IP="192.168.100.6"

ssh -i id_rsa ubuntu@$ADMIN_VM_IP

# Step 2C.3 Copy the files and change permissions

scp -i ./.ssh/id_rsa id_rsa.pub ubuntu@$ADMIN_VM_IP:/home/ubuntu/
scp -i ./.ssh/id_rsa id_rsa ubuntu@$ADMIN_VM_IP:/home/ubuntu/

chmod 600 /home/ubuntu/id_rsa
chmod 644 /home/ubuntu/id_rsa.pub