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

virsh net-define /mnt/extra/mgmt.xml && virsh net-autostart mgmt && virsh net-start mgmt
virsh net-define /mnt/extra/ds1.xml && virsh net-autostart ds1 && virsh net-start ds1
virsh net-define /mnt/extra/ds2.xml && virsh net-autostart ds2 && virsh net-start ds2
virsh net-define /mnt/extra/ss1.xml && virsh net-autostart ss1 && virsh net-start ss1
virsh net-define /mnt/extra/ss2.xml && virsh net-autostart ss2 && virsh net-start ss2

ip a && sudo virsh net-list --all

sleep 20

# Node 1
./kvm-install-vm create -c 4 -m 16384 -t rocky85 -d 120 -u rocky -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c1 n1

# Node 2
./kvm-install-vm create -c 4 -m 16384 -t rocky85 -d 120 -u rocky -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c2 n2

# Node 3
./kvm-install-vm create -c 4 -m 16384 -t rocky85 -d 120 -u rocky -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c3 n3

# Node 4
./kvm-install-vm create -c 4 -m 16384 -t rocky85 -d 120 -u rocky -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c4 n4

# Node 5
./kvm-install-vm create -c 4 -m 16384 -t rocky85 -d 120 -u rocky -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c5 n5

# Node 6
./kvm-install-vm create -c 4 -m 16384 -t rocky85 -d 120 -u rocky -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c6 n6

# Node 7
./kvm-install-vm create -c 4 -m 16384 -t rocky85 -d 120 -u rocky -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c7 n7

# Node 8
./kvm-install-vm create -c 4 -m 16384 -t rocky85 -d 120 -u rocky -f host-passthrough -k /root/.ssh/id_rsa.pub -l /mnt/extra/virt/images -L /mnt/extra/virt/vms -b mgmt -T US/Eastern -M 52:54:00:8a:8b:c8 n8

sleep 60

virsh list --all && brctl show && virsh net-list --all

for i in {1..8}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i 'echo "root:gprm8350" | sudo chpasswd'; done
for i in {1..8}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i 'echo "rocky:kyax7344" | sudo chpasswd'; done
for i in {1..8}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config"; done
for i in {1..8}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo systemctl restart sshd"; done
for i in {1..8}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "sudo rm -rf /root/.ssh/authorized_keys"; done

for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo dnf update -y"; done

for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo mkdir -p /etc/motd.d"; done

for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i 'cat << EOF | sudo tee /etc/motd.d/01-custom
****************************WARNING****************************************
UNAUTHORISED ACCESS IS PROHIBITED. VIOLATORS WILL BE PROSECUTED.
***************************************************************************
EOF'; done

for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo chmod +x /etc/motd.d/01-custom"; done

for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "cat << EOF | sudo tee /etc/modprobe.d/kvm.conf
options kvm_intel nested=1
EOF"; done

for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo modprobe -r kvm_intel && sudo modprobe -a kvm_intel"; done

for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo mkdir -p /etc/systemd/system/networking.service.d"; done
for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "cat << EOF | sudo tee /etc/systemd/system/networking.service.d/reduce-timeout.conf
[Service]
TimeoutStartSec=15
EOF"; done

for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo dnf makecache && sudo dnf install epel-release -y && sudo dnf makecache"; done
for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo dnf update -y && sudo dnf install -y git vim net-tools wget curl bash-completion iperf3 mtr traceroute netcat sshpass socat python3 python3-simplejson xfsprogs jq virtualenv"; done
for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo modprobe -v xfs && sudo grep xfs /proc/filesystems && sudo modinfo xfs"; done

for i in {1..8}; do virsh shutdown n$i; done && sleep 10 && virsh list --all && for i in {1..8}; do virsh start n$i; done && sleep 10 && virsh list --all

sleep 30

for i in {1..8}; do qemu-img create -f qcow2 vbdnode1$i.qcow2 120G; done
for i in {1..8}; do qemu-img create -f qcow2 vbdnode2$i.qcow2 120G; done
#for i in {1..8}; do qemu-img create -f qcow2 vbdnode3$i.qcow2 120G; done

for i in {1..8}; do ./kvm-install-vm attach-disk -d 120 -s /mnt/extra/kvm-install-vm/vbdnode1$i.qcow2 -t sdb n$i; done
for i in {1..8}; do ./kvm-install-vm attach-disk -d 120 -s /mnt/extra/kvm-install-vm/vbdnode2$i.qcow2 -t sdc n$i; done
#for i in {1..8}; do ./kvm-install-vm attach-disk -d 120 -s /mnt/extra/kvm-install-vm/vbdnode3$i.qcow2 -t sdd n$i; done

for i in {1..8}; do virsh attach-interface --domain n$i --type network --source ds1 --model virtio --config --live; done
for i in {1..8}; do virsh attach-interface --domain n$i --type network --source ds1 --model virtio --config --live; done
#for i in {1..8}; do virsh attach-interface --domain n$i --type network --source ss1 --model virtio --config --live; done
#for i in {1..8}; do virsh attach-interface --domain n$i --type network --source ss1 --model virtio --config --live; done

for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "cat << EOF | sudo tee /etc/hosts
127.0.0.1   localhost localhost.localdomain localhost4 localhost4.localdomain4
::1         localhost localhost.localdomain localhost6 localhost6.localdomain6
192.168.30.101  n1
192.168.30.102  n2
192.168.30.103  n3
192.168.30.104  n4
192.168.30.105  n5
192.168.30.106  n6
192.168.30.107  n7
192.168.30.108  n8
192.168.30.109  n9
EOF"; done

for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "cat << EOF | sudo tee /etc/sysctl.d/60-lxd-production.conf
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
net.ipv4.conf.all.forwarding=1
net.ipv6.conf.all.forwarding=1
EOF"; done

for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo sysctl --system"; done

for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "#echo vm.swappiness=1 | sudo tee -a /etc/sysctl.conf && sudo sysctl -p"; done

for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-eth0"; done
for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-eth1"; done
for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-eth2"; done
#for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-eth3"; done
#for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo rm -rf /etc/sysconfig/network-scripts/ifcfg-eth4"; done

### eth0
sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n1 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
HWADDR=52:54:00:8a:8b:c1
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n2 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
HWADDR=52:54:00:8a:8b:c2
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n3 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
HWADDR=52:54:00:8a:8b:c3
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n4 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
HWADDR=52:54:00:8a:8b:c4
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n5 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
HWADDR=52:54:00:8a:8b:c5
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n6 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
HWADDR=52:54:00:8a:8b:c6
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n7 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
HWADDR=52:54:00:8a:8b:c7
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n8 "cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-eth0
DEVICE=eth0
BOOTPROTO=dhcp
HWADDR=52:54:00:8a:8b:c8
MTU=9000
ONBOOT=yes
TYPE=Ethernet
USERCTL=no
EOF"

for i in {1..8}; do ssh -o "StrictHostKeyChecking=no" rocky@n$i "uname -a"; done
for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o "StrictHostKeyChecking=no" root@n$i "hostnamectl set-hostname n$i --static"; done
for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o "StrictHostKeyChecking=no" root@n$i "modprobe 8021q"; done
for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o "StrictHostKeyChecking=no" root@n$i "modprobe bonding"; done
for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o "StrictHostKeyChecking=no" root@n$i "lsmod | grep 8021q"; done
for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o "StrictHostKeyChecking=no" root@n$i "lsmod | grep bonding"; done
for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o "StrictHostKeyChecking=no" root@n$i "echo 8021q >> /etc/modules-load.d/8021q.conf"; done
for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o "StrictHostKeyChecking=no" root@n$i "echo bonding >> /etc/modules"; done

for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o "StrictHostKeyChecking=no" root@n$i "cp /etc/sysconfig/network-scripts/ifcfg-eth1 /tmp/ifcfg-eth1"; done
for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o "StrictHostKeyChecking=no" root@n$i "cp /etc/sysconfig/network-scripts/ifcfg-eth2 /tmp/ifcfg-eth2"; done
#for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o "StrictHostKeyChecking=no" root@n$i "cp /etc/sysconfig/network-scripts/ifcfg-eth3 /tmp/ifcfg-eth3"; done
#for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o "StrictHostKeyChecking=no" root@n$i "cp /etc/sysconfig/network-scripts/ifcfg-eth4 /tmp/ifcfg-eth4"; done

### Bond port configuration
for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o "StrictHostKeyChecking=no" root@n$i "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-eth1
NAME=bond-slave-eth1
MASTER=bond1
SLAVE=yes
EOF"; done

for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o "StrictHostKeyChecking=no" root@n$i "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-eth2
NAME=bond-slave-eth2
MASTER=bond1
SLAVE=yes
EOF"; done

#for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o "StrictHostKeyChecking=no" root@n$i "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-eth3
#NAME=bond-slave-eth3
#MASTER=bond2
#SLAVE=yes
#EOF"; done

#for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o "StrictHostKeyChecking=no" root@n$i "cat << EOF | sudo tee -a /etc/sysconfig/network-scripts/ifcfg-eth4
#NAME=bond-slave-eth4
#MASTER=bond2
#SLAVE=yes
#EOF"; done

### bond1
sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n1 'cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1
DEVICE=bond1
NAME=bond1
IPADDR=192.168.30.101
NETMASK=255.255.255.0
ONBOOT=yes
BOOTPROTO=none
TYPE=Bond
BONDING_MASTER=yes
BONDING_OPTS="mode=active-backup primary=eth1 miimon=100 primary_reselect=always fail_over_mac=follow use_carrier=0"
EOF'

sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n2 'cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1
DEVICE=bond1
NAME=bond1
IPADDR=192.168.30.102
NETMASK=255.255.255.0
ONBOOT=yes
BOOTPROTO=none
TYPE=Bond
BONDING_MASTER=yes
BONDING_OPTS="mode=active-backup primary=eth1 miimon=100 primary_reselect=always fail_over_mac=follow use_carrier=0"
EOF'

sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n3 'cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1
DEVICE=bond1
NAME=bond1
IPADDR=192.168.30.103
NETMASK=255.255.255.0
ONBOOT=yes
BOOTPROTO=none
TYPE=Bond
BONDING_MASTER=yes
BONDING_OPTS="mode=active-backup primary=eth1 miimon=100 primary_reselect=always fail_over_mac=follow use_carrier=0"
EOF'

sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n4 'cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1
DEVICE=bond1
NAME=bond1
IPADDR=192.168.30.104
NETMASK=255.255.255.0
ONBOOT=yes
BOOTPROTO=none
TYPE=Bond
BONDING_MASTER=yes
BONDING_OPTS="mode=active-backup primary=eth1 miimon=100 primary_reselect=always fail_over_mac=follow use_carrier=0"
EOF'

sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n5 'cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1
DEVICE=bond1
NAME=bond1
IPADDR=192.168.30.105
NETMASK=255.255.255.0
ONBOOT=yes
BOOTPROTO=none
TYPE=Bond
BONDING_MASTER=yes
BONDING_OPTS="mode=active-backup primary=eth1 miimon=100 primary_reselect=always fail_over_mac=follow use_carrier=0"
EOF'

sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n6 'cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1
DEVICE=bond1
NAME=bond1
IPADDR=192.168.30.106
NETMASK=255.255.255.0
ONBOOT=yes
BOOTPROTO=none
TYPE=Bond
BONDING_MASTER=yes
BONDING_OPTS="mode=active-backup primary=eth1 miimon=100 primary_reselect=always fail_over_mac=follow use_carrier=0"
EOF'

sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n7 'cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1
DEVICE=bond1
NAME=bond1
IPADDR=192.168.30.107
NETMASK=255.255.255.0
ONBOOT=yes
BOOTPROTO=none
TYPE=Bond
BONDING_MASTER=yes
BONDING_OPTS="mode=active-backup primary=eth1 miimon=100 primary_reselect=always fail_over_mac=follow use_carrier=0"
EOF'

sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n8 'cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond1
DEVICE=bond1
NAME=bond1
IPADDR=192.168.30.108
NETMASK=255.255.255.0
ONBOOT=yes
BOOTPROTO=none
TYPE=Bond
BONDING_MASTER=yes
BONDING_OPTS="mode=active-backup primary=eth1 miimon=100 primary_reselect=always fail_over_mac=follow use_carrier=0"
EOF'

### bond2
#for i in {1..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i 'cat << EOF | sudo tee /etc/sysconfig/network-scripts/ifcfg-bond2
#DEVICE=bond2
#NAME=bond2
#ONBOOT=yes
#BOOTPROTO=none
#TYPE=Bond
#BONDING_MASTER=yes
#BONDING_OPTS="mode=active-backup primary=eth3 miimon=100 primary_reselect=always fail_over_mac=follow use_carrier=0"
#EOF'; done

for i in {1..8}; do virsh shutdown n$i; done && sleep 90 && virsh list --all && for i in {1..8}; do virsh start n$i; done && sleep 90 && virsh list --all

sleep 30

### Load Balancers configuration
for i in {7..8}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo dnf install -y keepalived haproxy"; done

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
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo swapoff -a"; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config"; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo dnf install -y iproute-tc"; done

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

for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable.repo https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/CentOS_8/devel:kubic:libcontainers:stable.repo"; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "export VERSION=1.24.2 && sudo curl -L -o /etc/yum.repos.d/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$VERSION/CentOS_8/devel:kubic:libcontainers:stable:cri-o:$VERSION.repo"; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo dnf install -y cri-o"; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo systemctl enable cri-o"; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo systemctl start cri-o"; done

for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "cat << EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
exclude=kubelet kubeadm kubectl
EOF"; done

for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo dnf install -y kubelet kubeadm kubectl --disableexcludes=kubernetes"; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo systemctl enable kubelet"; done
for i in {1..6}; do sshpass -f /mnt/extra/kvm-install-vm/rocky ssh -o StrictHostKeyChecking=no root@n$i "sudo systemctl start kubelet"; done
