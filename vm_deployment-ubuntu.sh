#!/bin/bash
#
HOME=/mnt/extra/

cat > /mnt/extra/mgmt.xml <<EOF
<network>
  <name>mgmt</name>
  <forward mode='nat'/>
  <bridge name='mgmt' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:ca'/>
  <ip address='192.168.254.1' netmask='255.255.255.0'>
    <dhcp>
      <range start='192.168.254.2' end='192.168.254.249'/>
      <host mac='52:54:00:8a:8b:c1' name='n1' ip='192.168.254.101'/>
      <host mac='52:54:00:8a:8b:c2' name='n2' ip='192.168.254.102'/>
      <host mac='52:54:00:8a:8b:c3' name='n3' ip='192.168.254.103'/>
      <host mac='52:54:00:8a:8b:c4' name='n4' ip='192.168.254.104'/>
      <host mac='52:54:00:8a:8b:c5' name='n5' ip='192.168.254.105'/>
      <host mac='52:54:00:8a:8b:c6' name='n6' ip='192.168.254.106'/>
      <host mac='52:54:00:8a:8b:c7' name='n7' ip='192.168.254.107'/>
      <host mac='52:54:00:8a:8b:c8' name='n8' ip='192.168.254.108'/>
      <host mac='52:54:00:8a:8b:c9' name='n9' ip='192.168.254.109'/>
    </dhcp>
  </ip>
</network>
EOF

cat > /mnt/extra/ds1.xml <<EOF
<network>
  <name>ds1</name>
  <forward mode='nat'/>  
  <bridge name='ds1' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
  <mac address='52:54:00:8a:8b:cb'/>
  <ip address='192.168.30.1' netmask='255.255.255.0'>
  </ip>  
</network>
EOF

cat > /mnt/extra/ds2.xml <<EOF
<network>
  <name>ds2</name>  
  <bridge name='ds2' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/> 
</network>
EOF

cat > /mnt/extra/ss1.xml <<EOF
<network>
  <name>ss1</name>
  <bridge name='ss1' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
</network>
EOF

cat > /mnt/extra/ss2.xml <<EOF
<network>
  <name>ss2</name>
  <bridge name='ss2' stp='off' macTableManager="kernel"/>
  <mtu size="9216"/>
</network>
EOF

cat > /mnt/extra/pci_device_1.xml <<EOF
<hostdev mode='subsystem' type='pci' managed='yes'>
<driver name='vfio' />
<source>
<address domain='0x0000' bus='0x6b' slot='0x00' function='0x01' />
</source>
</hostdev>
EOF

virsh net-define /mnt/extra/mgmt.xml && virsh net-autostart mgmt && virsh net-start mgmt
virsh net-define /mnt/extra/ds1.xml && virsh net-autostart ds1 && virsh net-start ds1
virsh net-define /mnt/extra/ds2.xml && virsh net-autostart ds2 && virsh net-start ds2
virsh net-define /mnt/extra/ss1.xml && virsh net-autostart ss1 && virsh net-start ss1
virsh net-define /mnt/extra/ss2.xml && virsh net-autostart ss2 && virsh net-start ss2

ip a && sudo virsh net-list --all

sleep 20

# Node 1
./kvm-install-vm create -c 4 -m 16384 -t ubuntu2004 -d 120 -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c1 n1

# Node 2
./kvm-install-vm create -c 4 -m 16384 -t ubuntu2004 -d 120 -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c2 n2

# Node 3
./kvm-install-vm create -c 4 -m 16384 -t ubuntu2004 -d 120 -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c3 n3

# Node 4
./kvm-install-vm create -c 4 -m 16384 -t ubuntu2004 -d 120 -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c4 n4

# Node 5
./kvm-install-vm create -c 4 -m 16384 -t ubuntu2004 -d 120 -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c5 n5

# Node 6
./kvm-install-vm create -c 4 -m 16384 -t ubuntu2004 -d 120 -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c6 n6

# Node 7
./kvm-install-vm create -c 4 -m 16384 -t ubuntu2004 -d 120 -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c7 n7

# Node 8
./kvm-install-vm create -c 4 -m 16384 -t ubuntu2004 -d 120 -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c8 n8

# Node 9
./kvm-install-vm create -c 4 -m 16384 -t ubuntu2004 -d 120 -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c9 n9

sleep 60

virsh list --all && brctl show && virsh net-list --all

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i 'echo "root:gprm8350" | sudo chpasswd'; done
for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i 'echo "ubuntu:kyax7344" | sudo chpasswd'; done
for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config"; done
for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config"; done
for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo systemctl restart sshd"; done
for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo rm -rf /root/.ssh/authorized_keys"; done

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo hostnamectl set-hostname n$i --static"; done

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo apt update -y && sudo apt-get install -y git vim net-tools wget curl bash-completion apt-utils iperf iperf3 mtr traceroute netcat sshpass socat python3 python3-simplejson xfsprogs locate jq ifenslave"; done

#for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo apt-get install ntp ntpdate -y && sudo timedatectl set-ntp on"; done

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo modprobe bonding"; done
for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "lsmod | grep bond"; done

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo modprobe -v xfs && sudo grep xfs /proc/filesystems && sudo modinfo xfs && sudo mkdir -p /etc/apt/sources.list.d"; done

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo chmod -x /etc/update-motd.d/*"; done

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i 'cat << EOF | sudo tee /etc/update-motd.d/01-custom
#!/bin/sh
echo "****************************WARNING****************************************
UNAUTHORISED ACCESS IS PROHIBITED. VIOLATORS WILL BE PROSECUTED.
*********************************************************************************"
EOF'; done

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo chmod +x /etc/update-motd.d/01-custom"; done

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "cat << EOF | sudo tee /etc/modprobe.d/qemu-system-x86.conf
options kvm_intel nested=1
EOF"; done

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo DEBIAN_FRONTEND=noninteractive apt-get install linux-generic-hwe-20.04 --install-recommends -y"; done
for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo apt autoremove -y && sudo apt --fix-broken install -y"; done

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo mkdir -p /etc/systemd/system/networking.service.d"; done
for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "cat << EOF | sudo tee /etc/systemd/system/networking.service.d/reduce-timeout.conf
[Service]
TimeoutStartSec=15
EOF"; done

for i in {1..9}; do virsh shutdown n$i; done && sleep 10 && virsh list --all && for i in {1..9}; do virsh start n$i; done && sleep 10 && virsh list --all

sleep 30

#for i in {1..9}; do virsh attach-device n$i /mnt/extra/pci_device_1.xml --config; done
#for i in {1..9}; do virsh destroy n$i; done && sleep 10
#for i in {1..9}; do virsh start n$i; done && sleep 10

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo apt update -y"; done

for i in {1..9}; do qemu-img create -f qcow2 vbdnode1$i 120G; done
#for i in {1..9}; do qemu-img create -f qcow2 vbdnode2$i 120G; done
#for i in {1..9}; do qemu-img create -f qcow2 vbdnode3$i 120G; done

for i in {1..9}; do ./kvm-install-vm attach-disk -d 120 -s /mnt/extra/kvm-install-vm/vbdnode1$i.qcow2 -t vdb n$i; done
#for i in {1..9}; do ./kvm-install-vm attach-disk -d 120 -s /mnt/extra/kvm-install-vm/vbdnode2$i.qcow2 -t vdc n$i; done
#for i in {1..9}; do ./kvm-install-vm attach-disk -d 120 -s /mnt/extra/kvm-install-vm/vbdnode3$i.qcow2 -t vdd n$i; done

for i in {1..9}; do virsh attach-interface --domain n$i --type network --source ds1 --model virtio --mac 02:00:aa:0a:01:1$i --config --live; done
for i in {1..9}; do virsh attach-interface --domain n$i --type network --source ds2 --model e1000e --mac 02:00:aa:0a:02:1$i --config --live; done
#for i in {1..9}; do virsh attach-interface --domain n$i --type network --source ss1 --model e1000e --mac 02:00:aa:0a:03:1$i --config --live; done
#for i in {1..9}; do virsh attach-interface --domain n$i --type network --source ss2 --model e1000e --mac 02:00:aa:0a:04:1$i --config --live; done

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "cat << EOF | sudo tee /etc/hosts
127.0.0.1 localhost
192.168.30.101  n1
192.168.30.102  n2
192.168.30.103  n3
192.168.30.104  n4
192.168.30.105  n5
192.168.30.106  n6
192.168.30.107  n7
192.168.30.108  n8
192.168.30.109  n9
# The following lines are desirable for IPv6 capable hosts
::1 ip6-localhost ip6-loopback
fe00::0 ip6-localnet
ff00::0 ip6-mcastprefix
ff02::1 ip6-allnodes
ff02::2 ip6-allrouters
ff02::3 ip6-allhosts
EOF"; done

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "cat << EOF | sudo tee /etc/sysctl.d/60-lxd-production.conf
fs.inotify.max_queued_events=1048576
fs.inotify.max_user_instances=1048576
fs.inotify.max_user_watches=1048576
vm.max_map_count=262144
kernel.dmesg_restrict=1
net.ipv4.neigh.default.gc_thresh3=8192
net.ipv6.neigh.default.gc_thresh3=8192
net.core.bpf_jit_limit=3000000000
kernel.keys.maxkeys=2000
kernel.keys.maxbytes=2000000
net.ipv4.ip_forward=1
EOF"; done

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "sudo sysctl --system"; done

for i in {1..9}; do ssh -o "StrictHostKeyChecking=no" ubuntu@n$i "#echo vm.swappiness=1 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p"; done

ssh -o "StrictHostKeyChecking=no" ubuntu@n1 "cat << EOF | sudo tee /etc/netplan/01-netcfg.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: true
      dhcp6: false
    enp8s0:
      dhcp4: false
      dhcp6: false
    enp9s0:
      dhcp4: false
      dhcp6: false
  bonds:
    bond1:
      interfaces: [enp8s0, enp9s0]
      addresses: [192.168.30.101/24]
      parameters:
        mode: active-backup
        primary: enp8s0
EOF"

ssh -o "StrictHostKeyChecking=no" ubuntu@n2 "cat << EOF | sudo tee /etc/netplan/01-netcfg.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: true
      dhcp6: false
    enp8s0:
      dhcp4: false
      dhcp6: false
    enp9s0:
      dhcp4: false
      dhcp6: false
  bonds:
    bond1:
      interfaces: [enp8s0, enp9s0]
      addresses: [192.168.30.102/24]
      parameters:
        mode: active-backup
        primary: enp8s0       
EOF"

ssh -o "StrictHostKeyChecking=no" ubuntu@n3 "cat << EOF | sudo tee /etc/netplan/01-netcfg.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: true
      dhcp6: false
    enp8s0:
      dhcp4: false
      dhcp6: false
    enp9s0:
      dhcp4: false
      dhcp6: false
  bonds:
    bond1:
      interfaces: [enp8s0, enp9s0]
      addresses: [192.168.30.103/24]
      parameters:
        mode: active-backup
        primary: enp8s0  
EOF"

ssh -o "StrictHostKeyChecking=no" ubuntu@n4 "cat << EOF | sudo tee /etc/netplan/01-netcfg.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: true
      dhcp6: false
    enp8s0:
      dhcp4: false
      dhcp6: false
    enp9s0:
      dhcp4: false
      dhcp6: false
  bonds:
    bond1:
      interfaces: [enp8s0, enp9s0]
      addresses: [192.168.30.104/24]
      parameters:
        mode: active-backup
        primary: enp8s0    
EOF"

ssh -o "StrictHostKeyChecking=no" ubuntu@n5 "cat << EOF | sudo tee /etc/netplan/01-netcfg.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: true
      dhcp6: false
    enp8s0:
      dhcp4: false
      dhcp6: false
    enp9s0:
      dhcp4: false
      dhcp6: false
  bonds:
    bond1:
      interfaces: [enp8s0, enp9s0]
      addresses: [192.168.30.105/24]
      parameters:
        mode: active-backup
        primary: enp8s0     
EOF"

ssh -o "StrictHostKeyChecking=no" ubuntu@n6 "cat << EOF | sudo tee /etc/netplan/01-netcfg.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: true
      dhcp6: false
    enp8s0:
      dhcp4: false
      dhcp6: false
    enp9s0:
      dhcp4: false
      dhcp6: false
  bonds:
    bond1:
      interfaces: [enp8s0, enp9s0]
      addresses: [192.168.30.106/24]
      parameters:
        mode: active-backup
        primary: enp8s0   
EOF"

ssh -o "StrictHostKeyChecking=no" ubuntu@n7 "cat << EOF | sudo tee /etc/netplan/01-netcfg.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: true
      dhcp6: false
    enp8s0:
      dhcp4: false
      dhcp6: false
    enp9s0:
      dhcp4: false
      dhcp6: false
  bonds:
    bond1:
      interfaces: [enp8s0, enp9s0]
      addresses: [192.168.30.107/24]
      parameters:
        mode: active-backup
        primary: enp8s0     
EOF"

ssh -o "StrictHostKeyChecking=no" ubuntu@n8 "cat << EOF | sudo tee /etc/netplan/01-netcfg.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: true
      dhcp6: false
    enp8s0:
      dhcp4: false
      dhcp6: false
    enp9s0:
      dhcp4: false
      dhcp6: false
  bonds:
    bond1:
      interfaces: [enp8s0, enp9s0]
      addresses: [192.168.30.108/24]
      parameters:
        mode: active-backup
        primary: enp8s0     
EOF"

ssh -o "StrictHostKeyChecking=no" ubuntu@n9 "cat << EOF | sudo tee /etc/netplan/01-netcfg.yaml
# This file describes the network interfaces available on your system
# For more information, see netplan(5).
network:
  version: 2
  renderer: networkd
  ethernets:
    enp1s0:
      dhcp4: true
      dhcp6: false
    enp8s0:
      dhcp4: false
      dhcp6: false
    enp9s0:
      dhcp4: false
      dhcp6: false
  bonds:
    bond1:
      interfaces: [enp8s0, enp9s0]
      addresses: [192.168.30.109/24]
      parameters:
        mode: active-backup
        primary: enp8s0       
EOF"

for i in {1..9}; do virsh shutdown n$i; done && sleep 10 && virsh list --all && for i in {1..9}; do virsh start n$i; done && sleep 10 && virsh list --all

sleep 30

### Load Balancers configuration
for i in {7..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo apt install -y keepalived haproxy"; done

for i in {7..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i 'cat << EOF | sudo tee  /etc/keepalived/check_apiserver.sh
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

for i in {7..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo chmod +x /etc/keepalived/check_apiserver.sh"; done

for i in {7..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i 'cat << EOF | sudo tee /etc/keepalived/keepalived.conf
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
    interface eth1
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

for i in {7..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo systemctl enable --now keepalived"; done

for i in {7..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i 'cat << EOF | sudo tee/etc/haproxy/haproxy.cfg
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
    server n1 192.168.30.101:6443 check fall 3 rise 2
    server n2 192.168.30.102:6443 check fall 3 rise 2
    server n3 192.168.30.103:6443 check fall 3 rise 2
EOF'; done

for i in {7..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo systemctl enable haproxy && sudo systemctl restart haproxy"; done

### Kubernetes nodes configuration
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "swapoff -a && sed -i '/swap/d' /etc/fstab"; done

for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "cat << EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF"; done

for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo modprobe overlay"; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo modprobe br_netfilter"; done

for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "cat << EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.ipv4.ip_forward                 = 1
net.bridge.bridge-nf-call-ip6tables = 1
EOF"; done

for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo sysctl --system"; done

for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i 'export OS=xUbuntu_20.04 && export VERSION=1.24 && echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list'; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i 'export OS=xUbuntu_20.04 && export VERSION=1.24 && curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -'; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i 'export OS=xUbuntu_20.04 && export VERSION=1.24 && echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$VERSION/$OS/ /" | sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.list'; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i 'export OS=xUbuntu_20.04 && export VERSION=1.24 && curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/$OS/Release.key | sudo apt-key add -'; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo apt update && sudo apt install -y cri-o cri-o-runc cri-tools"; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo systemctl enable crio.service"; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo systemctl start crio.service"; done

for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i 'apt-add-repository "deb http://apt.kubernetes.io/ kubernetes-xenial main"'; done

for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo apt update && sudo apt install -y kubelet kubeadm kubectl"; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo systemctl enable kubelet"; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo systemctl start kubelet"; done
