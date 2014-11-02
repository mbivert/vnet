mkns	earth
mkns	moon

mkveth	earth	eth0	moon	eth0

setmac	earth	eth0	00:00:00:00:00:01
setmac	moon	eth0	00:00:00:00:00:02

setip	earth	eth0	10.0.0.1/30
setip	moon	eth0	10.0.0.2/30

# Checking
check	earth	10.0.0.2
check	moon	10.0.0.1
