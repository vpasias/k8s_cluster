#!/bin/bash
#
# Kubevirt installation

# Point at latest release
export RELEASE=$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
# Deploy the KubeVirt operator
sudo kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-operator.yaml
sleep 60
sudo kubectl get pods -n kubevirt
# Create the KubeVirt CR (instance deployment request) which triggers the actual installation
sudo kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-cr.yaml
sleep 90
sudo kubectl get pods -n kubevirt
curl -L -o virtctl https://github.com/kubevirt/kubevirt/releases/download/${KUBEVIRT_VERSION}/virtctl-${KUBEVIRT_VERSION}-linux-amd64 && chmod +x virtctl
