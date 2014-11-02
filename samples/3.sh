mkns		leo
mkns		regulus
mkns		denebola

mkns		gemini
mkns		pollux
mkns		castor

mkns		orion
mkns		rigel
mkns		betelgeuse
mkns		bellatrix
mkns		saiph

# mkswitch	leo		rebulus		denebola
mkveth		leo		port0	regulus		eth0
mkveth		leo		port1	denebola	eth0
mkbridge	leo		eth0	port0		port1

mkveth		gemini	port0	pollux		eth0
mkveth		gemini	port1	castor		eth0
mkbridge	gemini	eth0	port0		port1

mkveth		orion	port0	rigel		eth0
mkveth		orion	port1	betelgeuse	eth0
mkveth		orion	port2	bellatrix	eth0
mkveth		orion	port3	saiph		eth0
mkbridge	orion	eth0	port0	port1	port2	port3

mkveth		leo		eth1	gemini		eth1
mkveth		gemini	eth2	orion		eth1

setip		leo			eth0	10.0.0.1/29
setip		regulus		eth0	10.0.0.2/29
setip		denebola	eth0	10.0.0.3/29

setip		gemini		eth0	172.16.0.1/29
setip		pollux		eth0	172.16.0.2/29
setip		castor		eth0	172.16.0.3/29

setip		orion		eth0	192.168.1.1/29
setip		rigel		eth0	192.168.1.2/29
setip		betelgeuse	eth0	192.168.1.3/29
setip		bellatrix	eth0	192.168.1.4/29
setip		saiph		eth0	192.168.1.5/29

setip		leo			eth1	10.1.0.1/30
setip		gemini		eth1	10.1.0.2/30

setip		gemini		eth2	10.2.0.1/30
setip		orion		eth1	10.2.0.2/30

setroute	regulus		default		10.0.0.1
setroute	denebola	default		10.0.0.1

setroute	pollux		default		172.16.0.1
setroute	castor		default		172.16.0.1

setroute	rigel		default		192.168.1.1
setroute	betelgeuse	default		192.168.1.1
setroute	bellatrix	default		192.168.1.1
setroute	saiph		default		192.168.1.1

# ---

setroute	leo			192.168.1.0/29	10.1.0.2
setroute	leo			172.16.0.0/29	10.1.0.2

setroute	gemini		10.0.0.0/29		10.1.0.1
setroute	gemini		192.168.1.0/29	10.2.0.2

setroute	orion		10.0.0.0/29		10.2.0.1
setroute	orion		172.16.0.0/29	10.2.0.1

check		rigel		10.0.0.2
check		regulus		192.168.1.2
check		bellatrix	172.16.0.2

