#!/bin/sh

# Gateway
gwns=gateway
ipgw=172.16.0.1/29
macgw=00:00:00:00:00:10
ifgws1=eth1
ifgws2=eth2

# ips and macs for server1
s1ns=server1
ips1=172.16.0.2/29
macs1gw=00:00:00:00:00:01
ifs1gw=eth0

# ips and macs for server2
s2ns=server2
ips2=172.16.0.3/29
macs2gw=00:00:00:00:00:02
ifs2gw=eth0

# Gateway interface to create virtual switch
br=br0

# permissions settings
user=mb
group=users

# temporary veth name
v0=veth0
v1=veth1

# exit on error
set -e

# Aliases
gwexec="ip netns exec $gwns"
s1exec="ip netns exec $s1ns"
s2exec="ip netns exec $s2ns"

clean() {
	# we may have error here
	set +e;

	# bring the interfaces down in every namespace
	$gwexec ip link set dev $ifgws1 down
	$gwexec ip link set dev $ifgws2 down
	$gwexec ip link set dev $br     down
	$gwexec ip link set dev lo      down

	$s1exec ip link set dev $ifs1gw down
	$s1exec ip link set dev lo      down

	$s2exec ip link set dev $ifs2gw down
	$s2exec ip link set dev lo      down

	# finally, delete them
	$gwexec ip link del $ifgws1 # will delete ifs1gw too
	$gwexec ip link del $ifgws2 # will delete ifs2gw too
	$gwexec ip link del $br

	# and remove namespaces
	ip netns del $gwns
	ip netns del $s1ns
	ip netns del $s2ns
}

# clean when anything goes wrong
trap clean SIGHUP SIGTERM SIGINT EXIT

# create namespaces
ip netns add $gwns
ip netns add $s1ns
ip netns add $s2ns

# setup loopback interfaces
$gwexec ip link set dev lo up
$s1exec ip link set dev lo up
$s2exec ip link set dev lo up

########################
## --- Link Layer --- ##
########################
# create veth interface gw<->s1
  # and set mac addresses
  #ip link add $v0 address $macgws1 type veth peer name $v1 address $macs1gw
  ip link add $v0 address $macgw type veth peer name $v1 address $macs1gw
  
  # set interface in namespaces
  ip link set $v0 netns $gwns
  ip link set $v1 netns $s1ns
  
  # rename them
  $gwexec ip link set dev $v0 name $ifgws1
  $s1exec ip link set dev $v1 name $ifs1gw
  
  # bring'em up
  $gwexec ip link set dev $ifgws1 up
  $s1exec ip link set dev $ifs1gw up
  
# create veth interface gw<->s2
  # and set mac addresses
  #ip link add $v0 address $macgws2 type veth peer name $v1 address $macs2gw
  ip link add $v0 address $macgw type veth peer name $v1 address $macs2gw
  
  # set interface in namespaces
  ip link set $v0 netns $gwns
  ip link set $v1 netns $s2ns
  
  # rename them
  $gwexec ip link set dev $v0 name $ifgws2
  $s2exec ip link set dev $v1 name $ifs2gw
  
  # bring'em up
  $gwexec ip link set dev $ifgws2 up
  $s2exec ip link set dev $ifs2gw up
  
# create the bridge (virtual switch)
  $gwexec ip link add name $br type bridge
  $gwexec ip link set $br address $macgw
  
  # add interface to the bridge
  $gwexec ip link set dev $ifgws1 master $br
  $gwexec ip link set dev $ifgws2 master $br
  
  # bring'it up
  $gwexec ip link set dev $br up

############################
## --- Internet Layer --- ##
############################
$gwexec ip addr add dev $br $ipgw
$s1exec ip addr add dev $ifs1gw $ips1
$s2exec ip addr add dev $ifs2gw $ips2

echo 'Press enter to exit...'
read
