#!/bin/bash

### Persistent Volume Storage for Nextcloud ###

# SSH To the admin VM first
# Note the IP of the admin machine
ADMIN_VM_IP="192.168.100.6"

ssh -i id_rsa ubuntu@$ADMIN_VM_IP


# Step 6.1 First we need to temporarily delete the nextcloud deployment

kubectl delete deployment nextcloud -n nextcloud


# Now we need to create persistent storage

# Step 6.2 Make a yaml file with persistent volume claims and a temporary pod 

# Define the output file
OUTPUT_FILE2="nextcloud-temp-pod.yaml"

# Create the YAML content
cat <<EOF > $OUTPUT_FILE2

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nextcloud-config-pvc
  namespace: nextcloud
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 10Mi
  storageClassName: longhorn

---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: nextcloud-data-pvc
  namespace: nextcloud
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 70Gi
  storageClassName: longhorn

---
apiVersion: v1
kind: Pod
metadata:
  name: nextcloud-temp-pod
  namespace: nextcloud
spec:
  containers:
  - name: nextcloud-temp-container
    image: busybox:1.35.0-uclibc
    command: [ "sleep", "3600" ]  # This will keep the pod running for up to 1 hour
    volumeMounts:
    - mountPath: /var/www/html/config
      name: nextcloud-config
    - mountPath: /var/www/html/data
      name: nextcloud-data
  volumes:
  - name: nextcloud-config
    persistentVolumeClaim:
      claimName: nextcloud-config-pvc
  - name: nextcloud-data
    persistentVolumeClaim:
      claimName: nextcloud-data-pvc

EOF

# Confirm the file was created
echo "YAML file '$OUTPUT_FILE2' has been created."

# Step 6.3 apply the yaml file and wait 20 seconds for it to start

kubectl apply -f nextcloud-config-temp.yaml

sleep 20

kubectl get pods -n nextcloud


# Step 6.4 Get the config folder copied to the persistent volume

POD_NAME=$(/usr/local/bin/kubectl get pods -n nextcloud -o jsonpath='{.items[0].metadata.name}')

kubectl cp ~/nextcloud-config/. $POD_NAME:/var/www/html/config/ -n nextcloud

# Confirm the copy worked
kubectl exec -it $POD_NAME -n nextcloud -- /bin/bash -c 'cat /var/www/html/config/config.php'


# Step 6.5  Delete the temporary pod
kubectl delete deployment nextcloud -n nextcloud


# Step 6.6 Download and apply a new config for nextcloud from a working yaml file with persistent storage

curl -sO https://raw.githubusercontent.com/benspilker/proxmox-k3s/main/NextcloudResources/nextcloud-deployment.yaml
kubectl apply -f nextcloud-deployment.yaml



# Step 6.7 Wait for new deployment to fully come back up as running

kubectl get pods -n nextcloud

sleep 120

kubectl get pods -n nextcloud

# Step 6.8, Once running, we likely need to change config and data folder permissions

POD_NAME=$(/usr/local/bin/kubectl get pods -n nextcloud -o jsonpath='{.items[0].metadata.name}')

kubectl exec -it $POD_NAME -n nextcloud -- /bin/bash -c 'chown -R www-data:www-data /var/www/html/config/config.php'
kubectl exec -it $POD_NAME -n nextcloud -- /bin/bash -c 'chmod -R 755 /var/www/html/config/config.php'
kubectl exec -it $POD_NAME -n nextcloud -- /bin/bash -c 'chmod 0770 /var/www/html/data
kubectl exec -it $POD_NAME -n nextcloud -- /bin/bash -c 'chown -R www-data:www-data /var/www/html/data'
kubectl exec -it $POD_NAME -n nextcloud -- /bin/bash -c 'chmod g-s /var/www/html/data'


####### YOU DID IT!!!! #############


# A couple other things to consider. This uses an SQLite database which is limited in its concurrency. To make this more robust for production PostgreSQL is recommended

# This takes some manipulation but it is doable. 

# We'll need to put the configuration into a setup where the database location is persistent but the config file is not

# The deployment called semi-persistent-nextcloud-deployment.yaml in the other subfolder does just that as data is consistent but the config file is not
# curl -sO https://raw.githubusercontent.com/benspilker/proxmox-k3s/main/NextcloudResources/OtherNextcloud/semi-persistent-nextcloud-deployment.yaml

# then apply this
# kubectl delete deployment nextcloud -n nextcloud
# kubectl apply -f semi-persistent-nextcloud-deployment.yaml
# then check for pods with 
# kubectl get pods -n nextcloud

# To fix the "Trusted domain" issue we'll need to run this again
# Note you may need to change the domain to match yours

# POD_NAME=$(/usr/local/bin/kubectl get pods -n nextcloud -o jsonpath='{.items[0].metadata.name}')

# /usr/local/bin/kubectl exec -it $POD_NAME -n nextcloud -- /bin/bash -c '
# CONFIG_PATH="/var/www/html/config/config.php"; 

# toppart=$(head -n 26 $CONFIG_PATH); 
# bottompart=$(tail -n +27 $CONFIG_PATH);    
# newline="   2 => \"nextcloud.ne-inc.com\",";    
#echo "$toppart$newline$bottompart" > $CONFIG_PATH'
	    
# kubectl cp $POD_NAME:/var/www/html/config/config.php -n nextcloud config.php
# Now the problem with this is we'll have a new config file we'll need to deal with which requires us to start back at the beginning of this script #6.
# kubectl delete deployment nextcloud -n nextcloud




