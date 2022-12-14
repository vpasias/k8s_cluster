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
if ip addr | grep -q 192.168.20.100; then
  curl --silent --max-time 2 --insecure https://192.168.20.100:6443/ -o /dev/null || errorExit "Error GET https://192.168.20.100:6443/"
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
    interface eth0
    virtual_router_id 1
    priority 100
    advert_int 5
    authentication {
        auth_type PASS
        auth_pass mysecret
    }
    virtual_ipaddress {
        192.168.20.100
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
    server n1 192.168.20.201:6443 check fall 3 rise 2
    server n2 192.168.20.202:6443 check fall 3 rise 2
    server n3 192.168.20.203:6443 check fall 3 rise 2
EOF'; done

for i in {7..8}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo systemctl enable haproxy && sudo systemctl restart haproxy"; done

### Kubernetes nodes configuration
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo swapoff -a"; done
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

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo dnf install -y yum-utils device-mapper-persistent-data lvm2"; done

# containerd installation
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo dnf update -y"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo dnf install -y docker-ce containerd.io"; done

for i in {1..6}; do sshpass -f /home/iason/k8s_cluster/rocky ssh -o StrictHostKeyChecking=no root@node-$i "mkdir -p /etc/containerd && containerd config default > /etc/containerd/config.toml"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo systemctl restart containerd"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo systemctl enable containerd"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo systemctl status containerd"; done

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

sleep 120

ssh -o StrictHostKeyChecking=no rocky@node-1 "sudo systemctl status kubelet"

sshpass -f /home/iason/k8s_cluster/rocky ssh -o StrictHostKeyChecking=no root@node-1 "kubeadm config images pull"

sshpass -f /home/iason/k8s_cluster/rocky ssh -o StrictHostKeyChecking=no root@node-1 'kubeadm init --control-plane-endpoint="192.168.20.100:6443" --upload-certs --apiserver-advertise-address=192.168.20.201 --pod-network-cidr=172.16.0.0/16 --token ayngk7.m1555duk5x2i3ctt --token-ttl 0 | tee /home/rocky/kubeadm.log'

sshpass -f /home/iason/k8s_cluster/rocky ssh -o StrictHostKeyChecking=no root@node-1 "kubectl --kubeconfig=/etc/kubernetes/admin.conf create -f https://docs.projectcalico.org/manifests/calico.yaml"

sudo apt install snapd -y
sudo snap install kubectl --classic

mkdir ~/.kube
sshpass -f /home/iason/k8s_cluster/rocky scp root@node-1:/etc/kubernetes/admin.conf ~/.kube/config
sshpass -f /home/iason/k8s_cluster/rocky scp root@node-1:/home/rocky/kubeadm.log ~/.kube/kubeadm.log
for i in {2..6}; do scp ~/.kube/kubeadm.log rocky@node-$i:/home/rocky/kubeadm.log; done

discovery_token_ca_cert_hash="$(grep 'discovery-token-ca-cert-hash' ~/.kube/kubeadm.log | head -n1 | awk '{print $2}')"
certificate_key="$(grep 'certificate-key' ~/.kube/kubeadm.log | head -n1 | awk '{print $3}')"

for i in {2..3}; do sshpass -f /home/iason/k8s_cluster/rocky ssh -o StrictHostKeyChecking=no root@node-$i "kubeadm join 192.168.20.100:6443 --token ayngk7.m1555duk5x2i3ctt --discovery-token-ca-cert-hash ${discovery_token_ca_cert_hash} --control-plane --certificate-key ${certificate_key} --apiserver-advertise-address=192.168.20.20$i"; done

sleep 10

for i in {4..6}; do sshpass -f /home/iason/k8s_cluster/rocky ssh -o StrictHostKeyChecking=no root@node-$i "kubeadm join 192.168.20.100:6443 --token ayngk7.m1555duk5x2i3ctt --discovery-token-ca-cert-hash ${discovery_token_ca_cert_hash}"; done

sleep 20

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh
helm version
helm repo remove stable || true

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo systemctl start docker && sudo systemctl enable docker && sudo systemctl status docker"; done
sleep 10
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo usermod -aG docker rocky"; done

sudo kubectl create namespace openstack
sudo kubectl create namespace ceph
sudo kubectl label --overwrite namespace default name=default
sudo kubectl label --overwrite namespace kube-system name=kube-system
sudo kubectl label --overwrite namespace kube-public name=kube-public
sudo kubectl label nodes --all openstack-control-plane=enabled
sudo kubectl label nodes --all openstack-compute-node=enabled
sudo kubectl label nodes --all openvswitch=enabled
sudo kubectl label nodes --all linuxbridge=enabled
sudo kubectl label nodes --all ceph-mon=enabled
sudo kubectl label nodes --all ceph-osd=enabled
sudo kubectl label nodes --all ceph-mds=enabled
sudo kubectl label nodes --all ceph-rgw=enabled
sudo kubectl label nodes --all ceph-mgr=enabled

sleep 10

ssh -o StrictHostKeyChecking=no rocky@node-1 'ssh-keygen -t rsa -N "" -f .ssh/id_rsa && for h in node-1 node-2 node-3 node-4 node-5 node-6 node-7 node-8 node-9; do sshpass -p gprm8350 ssh-copy-id -o "StrictHostKeyChecking=no" rocky@$h;done'
ssh -o StrictHostKeyChecking=no rocky@node-1 "sudo chown -R rocky: /opt && git clone https://opendev.org/openstack/openstack-helm-infra.git /opt/openstack-helm-infra && git clone https://opendev.org/openstack/openstack-helm.git /opt/openstack-helm"
for h in node-2 node-3 node-4 node-5 node-6; do ssh -o StrictHostKeyChecking=no rocky@$h "sudo chown -R rocky: /opt && git clone https://opendev.org/openstack/openstack-helm-infra.git /opt/openstack-helm-infra && git clone https://opendev.org/openstack/openstack-helm.git /opt/openstack-helm";done

sudo kubectl cluster-info
sudo kubectl get nodes -o wide --all-namespaces
sudo kubectl get pods -o wide --all-namespaces

ssh -o StrictHostKeyChecking=no rocky@node-1 "cat > /opt/openstack-helm-infra/tools/gate/devel/multinode-vars.yaml <<EOF
kubernetes_network_default_device: eth0
EOF"

ssh -o StrictHostKeyChecking=no rocky@node-1 "curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh && helm version && helm repo remove stable || true"
ssh -o StrictHostKeyChecking=no rocky@node-1 "mkdir -p /home/rocky/.kube && sudo cp -i /etc/kubernetes/admin.conf /home/rocky/.kube/config && sudo chown $(id -u):$(id -g) /home/rocky/.kube/config"
ssh -o StrictHostKeyChecking=no rocky@node-1 "kubectl taint nodes --all node-role.kubernetes.io/master-"
ssh -o StrictHostKeyChecking=no rocky@node-1 "kubectl taint nodes --all node-role.kubernetes.io/control-plane-"
ssh -o StrictHostKeyChecking=no rocky@node-1 "kubectl cluster-info && kubectl get nodes -o wide --all-namespaces && kubectl get pods -o wide --all-namespaces"
