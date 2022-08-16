#!/bin/bash
#

git clone https://github.com/prometheus-operator/kube-prometheus.git

sudo kubectl create -f /home/iason/k8s_cluster/kube-prometheus/manifests/setup/

sudo kubectl get ns monitoring

sudo kubectl get pods -n monitoring

sleep 120

sudo kubectl create -f /home/iason/k8s_cluster/kube-prometheus/manifests/

sleep 20

sudo kubectl get pods -n monitoring

sudo kubectl get svc -n monitoring
