mkns		sun

mkns		earth
mkns		moon

mkns		saturn
mkns		titan

mkveth		sun		port0	earth	eth0
mkveth		sun		port1	moon	eth0
mkbridge	sun		eth0	port0	port1

mkveth		sun		port2	saturn	eth0
mkveth		sun		port3	titan	eth0
mkbridge	sun		eth1	port2	port3

setip		sun		eth0	10.0.0.1/29
setip		earth	eth0	10.0.0.2/29
setip		moon	eth0	10.0.0.3/29

setip		sun		eth1	172.16.0.1/29
setip		saturn	eth0	172.16.0.2/29
setip		titan	eth0	172.16.0.3/29

setroute	earth	172.16.0.0/29	10.0.0.1
setroute	moon	172.16.0.0/29	10.0.0.1

setroute	saturn	10.0.0.0/29		172.16.0.1
setroute	titan	10.0.0.0/29		172.16.0.1

fwroute2	sun		eth0	10.0.0.0/29	eth1	172.16.0.0/29

check		saturn	10.0.0.2
check		moon	172.16.0.3
