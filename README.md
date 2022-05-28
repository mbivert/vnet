# Introduction
This directory contains tools to create virtual network on Linux. We
rely the following abstractions:

- A machine is a set of network interfaces within a single namespace.
- A switch is a list of virtual ethernet ends glued through a bridge.
- A router is a machine able to route traffic between two interfaces/network.

# mktap
Simple, standalone script to create/remove a bridged TUN/TAP interface,
typically for use with qemu(1).

# mknetns
Recent re-use of some of vnet.sh to create a a network namespace,
interconnected with "default" namespace, with Internet traffic
routing.

One use case is to give a "real" IP to a qemu(1) running
with the standard user-mode network/port redirections,
that is, as an alternative to the usual TUN/TAP+bridge
solution.

# mkswitch1.sh
Deprecated. Included for curiosity.

# Using vnet.sh
Usage:

    vnet.sh <configuration file>

Vnet.sh comes with a few simple functions over ip(8) and iptables(8) to
help setting up the network.

The "configuration file" is merely a call to those functions plus other
manual setup.

1. Creating the namespaces associated to the needed machines;
2. Configuring the Link Layer (ethernet links);
3. Configuring the Internet Layer (IP addresses and routes).

The first parts is done by a series of `mkns` calls, which creates
a named-namespace, and setup a working loopback interface within.

The second use mainly `mkveth` to create ethernet links between two
computers. Multiple ends of such links can be glued together via
`mkbridge`, thus creating switches.

The third parts starts by assigning IP addresses through `setip`.
It can then configure some boxes to do NAT via `donat` and configure
static routes through `setroute`. Packets forwarding can be done
through `doroute`.

# Tools
## utils/links.sh
Use [graphviz](http://www.graphviz.org/) to generate a simple graph of
machines interconnection from configuration file. One can surely extend
it to include more data, such as IPs, interfaces, etc.

## utils/genconf.awk
Awk script allowing to automatically generate network from a lists like
this (`samples/3.conf`):

    # CIDR         gateway? Machines...
    10.0.0.0/29     -g      leo     regulus  denebola
    172.16.0.0/29   -g      gemini  pollux   castor
    192.168.1.0/29  -g      orion   rigel    betelgeuse  bellatrix  saiph
    10.1.0.0/30             leo     gemini
    10.2.0.0/30             gemini  orion

The `-g` indicates that the first machine is the gateway for the
network. This will automatically set routes for other machines.

Note that `utils/genconf.awk`'s output is usually not ready for direct use:
it merely automatize the creation of a network.

You'll need [cidrc](https://github.com/mbivert/cidrc) to use this script,
or a program able to list availables IPs from a netwok CIDR.

# Samples
## samples/1.sh
This one creates a single network made of two machines, connected via
ethernet. Each one is assigned a MAC address and static IP.

## samples/2.sh
We extend the previous network by a router and another network.

## samples/3.sh, samples/3.conf
Now, we have 3 routers talking to each other, behind each of them
exist a network.

As you can see, it starts to gets really verbose. Hopefully, most of
it can be automatically generated through `utils/genconf.awk`:

    % utils/genconf.awk samples/3.conf > samples/3bis.sh

Append thoses routes to `samples/3bis.sh` to re-obtain `samples/3.sh`'s:

    setroute  leo     192.168.1.0/29  10.1.0.2
    setroute  leo     172.16.0.0/29   10.1.0.2

    setroute  gemini  10.0.0.0/29     10.1.0.1
    setroute  gemini  192.168.1.0/29  10.2.0.2

    setroute  orion   10.0.0.0/29     10.2.0.1
    setroute  orion   172.16.0.0/29   10.2.0.1

# Limitations/TODO
The `utis/genconf.awk` is still very limited:

- no two network with same cidr allowed (eg. NAT)
- not quite ready to support other network topologies than trees (ring, star, full-mesh)
- no IPv6

Overall, there has been no IPv6 tests.

