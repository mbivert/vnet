#!/bin/sh

if [ "$1" == "" ]; then
	echo usage: $0 '<configuration>' 1>&2
	exit 1
fi

# temporary veth name
v0=tmp0
v1=tmp1

set -e

# Each command creating something will append data to
# /tmp/$$.clean.sh. Later will be executed upon exit
clean=/tmp/$$.clean.sh
echo '#!/bin/sh' >> $clean
chmod +x $clean

trap "sh $clean && rm $clean" SIGHUP SIGINT SIGTERM EXIT

# execute args in a netmork namespace
# $1: namespace
# $*: command
exns() { ip netns exec $*; }

# create a namespace
# set loopack interface up
# $1 : namespace name
mkns() {
	ip netns add $1
	exns $1 ip link set dev lo up

	# related interfaces will be delete to.
	echo 'ip netns del' $1 >> $clean
}

# set the mac address of an interface
# $1: namespace name
# $2: interface name
# $3: mac address
setmac() { exns $1 ip link set dev $2 address $3; }

# set the ip address of an interface
# $1: namespace name
# $2: interface name
# $3: ip address
setip() { exns $1 ip addr add dev $2 $3; }

# create a pair of virtual ethernet devices
# set them up
# move them to the appropriate namespaces and rename
# $1 : namespace1
# $2 : interface name for namespace1
# $3 : namespace2
# $4 : interface name for namespace2
mkveth() {
	ip link add $v0 type veth peer name $v1

	ip link set dev $v0 netns $1
	ip link set dev $v1 netns $3

	exns $1 ip link set dev $v0 name $2
	exns $3 ip link set dev $v1 name $4

	exns $1 ip link set dev $2 up
	exns $3 ip link set dev $4 up
}

# Bridge interface together
# $1: namespace
# $2: bridge name (master)
# $*: interfaces to bridge
mkbridge() {
	ns=$1; shift
	br=$1; shift
	exns $ns ip link add name $br type bridge

	for i in $*; do
		exns $ns ip link set dev $i master $br
	done

	exns $ns ip link set dev $br up
}

# Enable IP forwarding
# $1 : namespace (useless)
dofw() {
	exns $1 echo 1 > /proc/sys/net/ipv4/ip_forward || \
	exns $1 sysctl net.ipv4.ip_forward=1
}

# Enable NAT
# $1: namespace
# $2: source interface
# $3: destination interface
donat() {
	dofw $1
	exns $1 iptables -t nat -D POSTROUTING -i $2 -o $3 -j MASQUERADE
}

# Add a routing rule
# $1: namespace
# $2: destination network (can be 'defautlt')
# $3: next-hop
setroute() {
	dofw $1
	exns $1 ip route add $2 via $3
}

# Set firewall to route traffic
# $1: namespace
# $2: source interface
# $3: source network
# $4: destination interface
# $5: destination network
fwroute() {
	dofw $1
	exns $1 iptables -I FORWARD -i $2 -o $4 -s $3 -d $5 -j ACCEPT
}

# Set firewall to route traffic 2-way
# $1: namespace
# $2: source interface
# $3: source network
# $4: destination interface
# $5: destination network
fwroute2() {
	doroute $1 $2 $3 $4 $5
	doroute $1 $4 $5 $2 $3
}

# Check (ICMP ping) a machine can contact a given IP and report
# $1: namespace
# $2: destination IP address
check() {
	exns $1 ping -c1 $2 2>&1 >/dev/null && \
		echo $1 '->' $2 : Ok
}

# load configuration
. ./$1

echo 'Press enter to leave...'
read
