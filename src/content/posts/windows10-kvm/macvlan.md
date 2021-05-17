+++
title = "Windows 10 KVM Single-GPU Passthrough - macvlan Script"
date = "2020-05-18"
hidden = true
+++

{{< highlight bash >}}
#!/bin/sh
# Last Edited: 2020-05-18
# From: https://www.furorteutonicus.eu/2013/08/04/enabling-host-guest-networking-with-kvm-macvlan-and-macvtap/
  
# Let host and guests talk to each other over macvlan.
# Configures a macvlan interface on the hypervisor.
# Run this on the hypervisor (e.g. in /etc/rc.local)
# Made for IPv4; need modification for IPv6.
# Meant for a simple network setup with only eth0,
# and a static (manual) ip config.
# Evert Mouw, 2013. Slightly modified in 2020.
 
HWLINK=enp34s0
MACVLN=macvlan0
TESTHOST=www.google.com
 
# ------------
# test if interface already exists
# ------------
if ip link show | grep "$MACVLN@$HWLINK" > /dev/null
then
	echo "Link $MACVLN already exists on $HWLINK."
	exit
fi
 
# ------------
# wait for network availability
# ------------
 
while ! ping -q -c 1 $TESTHOST > /dev/null
do
	echo "$0: Cannot ping $TESTHOST, waiting another 5 seconds."
	sleep 5
done
 
# ------------
# get network config
# ------------
 
IP=$(ip address show dev $HWLINK | grep "inet " | awk '{print $2}')
NETWORK=$(ip -o route | grep $HWLINK | grep -v default | awk '{print $1}')
GATEWAY=$(ip -o route | grep default | awk '{print $3}')
 
# ------------
# setting up $MACVLN interface
# ------------
 
ip link add $MACVLN link $HWLINK type macvlan mode bridge
ip address add $IP dev $MACVLN
ip link set dev $MACVLN up
 
# ------------
# routing table
# ------------
 
# empty routes
ip route flush dev $HWLINK
ip route flush dev $MACVLN
 
# add routes
ip route add $NETWORK dev $MACVLN metric 0
 
# add the default gateway
ip route add default via $GATEWAY
{{< /highlight >}}