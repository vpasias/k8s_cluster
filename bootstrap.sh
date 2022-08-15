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
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo dnf install -y iproute-tc"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "cat << EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo modprobe overlay"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo modprobe br_netfilter"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "cat << EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo sysctl --system"; done

for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8_Stream/devel:kubic:libcontainers:stable.repo"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:1.24.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:1.24/CentOS_8_Stream/devel:kubic:libcontainers:stable:cri-o:1.24.repo"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo dnf install -y cri-o"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo systemctl daemon-reload && sudo systemctl enable cri-o"; done
for i in {1..6}; do ssh -o StrictHostKeyChecking=no rocky@node-$i "sudo systemctl start cri-o"; done

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
