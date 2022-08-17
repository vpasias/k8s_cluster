#!/bin/bash
#

sudo kubectl create namespace monitoring

# Add prometheus-community repo
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Update helm repo
helm repo update

# Install helm charts
helm install prometheus prometheus-community/kube-prometheus-stack --namespace monitoring

#git clone https://github.com/prometheus-operator/kube-prometheus.git
#sudo kubectl apply --server-side -f /home/iason/k8s_cluster/kube-prometheus/manifests/setup
#sleep 120
#until sudo kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done
#sudo kubectl apply -f /home/iason/k8s_cluster/kube-prometheus/manifests/

sleep 120

sudo kubectl get svc -n monitoring

sudo kubectl get pods -n monitoring
