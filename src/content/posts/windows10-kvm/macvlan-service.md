+++
title = "Windows 10 KVM Single-GPU Passthrough - macvlan Service"
date = "2020-05-18"
hidden = true
+++

{{< highlight bash >}}
# /etc/systemd/system/macvlan.service
 
[Unit]
Description=MACVLAN bridge to share a physical network interface with KVM/QEMU hosts.
Documentation=https://www.furorteutonicus.eu/2013/08/04/enabling-host-guest-networking-with-kvm-macvlan-and-macvtap/
After=network-online.target
Wants=network-online.target
Before=libvirt-guests.service
 
[Service]
Type=oneshot
RemainAfterExit=yes
ExecStart=/home/phoenix/macvlan/macvlan.sh
 
[Install]
WantedBy=multi-user.target
{{< /highlight >}}