#!/bin/bash
#

### Load Balancers configuration
for i in {7..8}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo dnf install -y keepalived haproxy"; done

for i in {7..8}; do ssh -o StrictHostKeyChecking=no rocky@node-$i 'cat << EOF | sudo tee  /etc/keepalived/check_apiserver.sh
#!/bin/sh
errorExit() {
  echo "*** $@" 1>&2
  exit 1
}
curl --silent --max-time 2 --insecure https://localhost:6443/ -o /dev/null || errorExit "Error GET https://localhost:6443/"
if ip addr | grep -q 192.168.30.100; then
  curl --silent --max-time 2 --insecure https://192.168.30.100:6443/ -o /dev/null || errorExit "Error GET https://192.168.30.100:6443/"
fi
EOF'; done

for i in {7..8}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo chmod +x /etc/keepalived/check_apiserver.sh"; done

for i in {7..8}; do ssh -o StrictHostKeyChecking=no rocky@node-$i 'cat << EOF | sudo tee /etc/keepalived/keepalived.conf
vrrp_script check_apiserver {
  script "/etc/keepalived/check_apiserver.sh"
  interval 3
  timeout 10
  fall 5
  rise 2
  weight -2
}
vrrp_instance VI_1 {
    state BACKUP
    interface bond1
    virtual_router_id 1
    priority 100
    advert_int 5
    authentication {
        auth_type PASS
        auth_pass mysecret
    }
    virtual_ipaddress {
        192.168.30.100
    }
    track_script {
        check_apiserver
    }
}
EOF'; done

for i in {7..8}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo systemctl enable --now keepalived && sudo systemctl start keepalived"; done

for i in {7..8}; do ssh -o StrictHostKeyChecking=no rocky@node-$i 'cat << EOF | sudo tee /etc/haproxy/haproxy.cfg
frontend kubernetes-frontend
  bind *:6443
  mode tcp
  option tcplog
  default_backend kubernetes-backend
backend kubernetes-backend
  option httpchk GET /healthz
  http-check expect status 200
  mode tcp
  option ssl-hello-chk
  balance roundrobin
    server n1 192.168.30.201:6443 check fall 3 rise 2
    server n2 192.168.30.202:6443 check fall 3 rise 2
    server n3 192.168.30.203:6443 check fall 3 rise 2
EOF'; done

for i in {7..8}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo systemctl enable haproxy && sudo systemctl restart haproxy"; done

### Kubernetes nodes configuration
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo swapoff -a"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i 'echo "DefaultLimitMEMLOCK=16384" | sudo tee -a /etc/systemd/system.conf'; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo systemctl daemon-reexec"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo dnf install -y iproute-tc"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "cat << EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo modprobe overlay"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo modprobe br_netfilter"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "cat << EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_nonlocal_bind = 1
net.ipv4.ip_forward = 1
vm.swappiness=0
EOF"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo sysctl --system"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo rm -rf /etc/resolv.conf"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "cat << EOF | sudo tee /etc/resolv.conf
nameserver 10.96.0.10
nameserver 8.8.8.8
nameserver 8.8.4.4
search svc.cluster.local cluster.local
options ndots:5 timeout:1 attempts:1
EOF"; done

# Install Docker
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo dnf install docker-ce -y"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo dnf install socat jq util-linux bridge-utils libffi-devel ipvsadm make bc git-review -y"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo -E mkdir -p /etc/docker"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i 'sudo -E tee /etc/docker/daemon.json <<EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "live-restore": true
}
EOF'; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo systemctl start docker"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo systemctl enable docker"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "cat << EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo systemctl enable kubelet"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo systemctl start kubelet"; done

sleep 30

ssh -o StrictHostKeyChecking=no rocky@node-1 "sudo systemctl status kubelet"

# Kubernetes Version: v1.25.3
ssh -o StrictHostKeyChecking=no rocky@node-1 'cat << EOF | sudo tee kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta3
kind: InitConfiguration
bootstrapTokens:
- token: "ayngk7.m1555duk5x2i3ctt"
  description: "default kubeadm bootstrap token"
  ttl: "0"
--
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta3
kubernetesVersion: v1.25.3
controlPlaneEndpoint: 192.168.30.100:6443
apiServer:
  advertise:
    address: 192.168.30.201
networking:
  podSubnet: 172.16.0.0/16
--
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: cgroupfs
EOF'

sshpass -f /home/iason/k8s_cluster/rocky ssh -o StrictHostKeyChecking=no root@node-1 'kubeadm init --config /home/rocky/kubeadm-config.yaml --upload-certs | tee /home/rocky/kubeadm.log'

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "wget https://github.com/mikefarah/yq/releases/download/v4.6.0/yq_linux_amd64.tar.gz -O - | tar xz && sudo mv yq_linux_amd64 /usr/local/bin/yq"; done

# Calico version: v3.24
sshpass -f /home/iason/k8s_cluster/rocky ssh -o StrictHostKeyChecking=no root@node-1 "curl https://docs.projectcalico.org/v3.24/manifests/calico.yaml -o /tmp/calico.yaml"

sshpass -f /home/iason/k8s_cluster/rocky ssh -o StrictHostKeyChecking=no root@node-1 "sed -i -e 's#docker.io/calico/#quay.io/calico/#g' /tmp/calico.yaml"

# Download images needed for calico before applying manifests, so that `kubectl wait` timeout for `k8s-app=kube-dns` isn't reached by slow download speeds
sshpass -f /home/iason/k8s_cluster/rocky ssh -o StrictHostKeyChecking=no root@node-1 "awk '/image:/ { print $2 }' /tmp/calico.yaml | xargs -I{} sudo docker pull {}"

sshpass -f /home/iason/k8s_cluster/rocky ssh -o StrictHostKeyChecking=no root@node-1 "kubectl --kubeconfig=/etc/kubernetes/admin.conf apply -f /tmp/calico.yaml"

# Note: Patch calico daemonset to enable Prometheus metrics and annotations
ssh -o StrictHostKeyChecking=no rocky@node-1 'cat << EOF | sudo tee /tmp/calico-node.yaml
spec:
  template:
    metadata:
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9091"
    spec:
      containers:
        - name: calico-node
          env:
            - name: FELIX_PROMETHEUSMETRICSENABLED
              value: "true"
            - name: FELIX_PROMETHEUSMETRICSPORT
              value: "9091"
            - name: FELIX_IGNORELOOSERPF
              value: "true"
EOF'
sshpass -f /home/iason/k8s_cluster/rocky ssh -o StrictHostKeyChecking=no root@node-1 'kubectl -n kube-system patch daemonset calico-node --patch "$(cat /tmp/calico-node.yaml)"'

sleep 240

sudo apt install snapd -y
sudo snap install kubectl --classic

mkdir ~/.kube
sshpass -f /home/iason/k8s_cluster/rocky scp root@node-1:/etc/kubernetes/admin.conf ~/.kube/config
sshpass -f /home/iason/k8s_cluster/rocky scp root@node-1:/home/rocky/kubeadm.log ~/.kube/kubeadm.log
for i in {2..6}; do scp ~/.kube/kubeadm.log rocky@node-$i:/home/rocky/kubeadm.log; done

discovery_token_ca_cert_hash="$(grep 'discovery-token-ca-cert-hash' ~/.kube/kubeadm.log | head -n1 | awk '{print $2}')"
certificate_key="$(grep 'certificate-key' ~/.kube/kubeadm.log | head -n1 | awk '{print $3}')"

for i in {2..3}; do sshpass -f /home/iason/k8s_cluster/rocky ssh -o StrictHostKeyChecking=no root@node-$i "kubeadm join 192.168.30.100:6443 --token ayngk7.m1555duk5x2i3ctt --discovery-token-ca-cert-hash ${discovery_token_ca_cert_hash} --control-plane --certificate-key ${certificate_key} --apiserver-advertise-address=192.168.30.20$i"; done

sleep 10

for i in {4..6}; do sshpass -f /home/iason/k8s_cluster/rocky ssh -o StrictHostKeyChecking=no root@node-$i "kubeadm join 192.168.30.100:6443 --token ayngk7.m1555duk5x2i3ctt --discovery-token-ca-cert-hash ${discovery_token_ca_cert_hash}"; done

# Taint the nodes so that the pods can be deployed on master nodes.
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "kubectl taint nodes --all node-role.kubernetes.io/master-"; done
