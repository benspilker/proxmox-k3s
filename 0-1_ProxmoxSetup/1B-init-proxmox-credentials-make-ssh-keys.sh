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