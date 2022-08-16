#!/bin/bash
#

git clone https://github.com/prometheus-operator/kube-prometheus.git

sudo kubectl apply --server-side -f /home/iason/k8s_cluster/kube-prometheus/manifests/setup

until sudo kubectl get servicemonitors --all-namespaces ; do date; sleep 1; echo ""; done

sudo kubectl apply -f /home/iason/k8s_cluster/kube-prometheus/manifests/

sleep 20

sudo kubectl get svc -n monitoring

sudo kubectl get pods -n monitoring
