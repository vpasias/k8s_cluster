#!/bin/bash
#

git clone --single-branch --branch release-1.9 https://github.com/rook/rook.git
cd /home/iason/k8s_cluster/rook/deploy/examples/ 
sudo kubectl create -f crds.yaml
sleep 5
sudo kubectl create -f common.yaml
sudo kubectl create -f operator.yaml
sudo kubectl get all -n rook-ceph
sleep 120
sudo kubectl -n rook-ceph get pod
sudo kubectl config set-context --current --namespace rook-ceph
sudo kubectl create -f /home/iason/k8s_cluster/cluster.yaml
