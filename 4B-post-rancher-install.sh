#!/bin/bash

# Step 4B.1 Note, once inside rancher ui, install longhorn manually by clicking on the longhorn install in apps

# Step 4B.2 Then after longhorn installed, mark test-k3s-04 and test-k3s-05 as non-schedule-able nodes in longhorn
kubectl label nodes test-k3s-04 longhorn.storage/disable=true
kubectl label nodes test-k3s-05 longhorn.storage/disable=true

# Step 4B.3 Install traefik for ingress

curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

helm repo add traefik https://traefik.github.io/charts
helm repo update

helm install traefik traefik/traefik --namespace kube-system --create-namespace

kubectl get pods -n kube-system