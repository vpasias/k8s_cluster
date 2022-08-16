#!/bin/bash
#

git clone --single-branch --branch release-1.9 https://github.com/rook/rook.git && cd rook/deploy/examples/ 
kubectl create -f crds.yaml
sleep 5
kubectl create -f common.yaml
kubectl create -f operator.yaml
kubectl get all -n rook-ceph
sleep 60
kubectl -n rook-ceph get pod
kubectl config set-context --current --namespace rook-ceph
