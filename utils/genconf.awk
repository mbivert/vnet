#!/home/mb/plan9/bin/awk -f
#!/bin/awk -f

# TODO Allow same network cidr multiple times : eg. valid because NAT
# TODO Allow other topologies than trees (mesh, full-mesh, ring)

!/^#/ && !/^[ \t]*$/ {
	# Generate a list of IPs
	# ips[1] will be .0, so we goes till NF to have one more
	for (i=1; i <= NF; i++) {
		"cidrc list "$1 | getline ips[i]
	}

	i = 2; j = 0
	if ($i == "-g") { gateway[$1] = 1; i++; j=1 }
	# skip ips[1] (*.0)
	networks[$1] = $i SUBSEP ips[i-j]
	machines[$i] = 1
	i++
	for (; i <= NF; i++) {
		machines[$i] = 1
		networks[$1] = networks[$1] "\n" $i SUBSEP ips[i-j]
	}
}

END {
	print "# Summary"
 	for (n in networks) {
 		print "#\t" n": "
 		for (m=1; m <= split(networks[n], ms, "\n"); m++) {
  			gw = ""; if (gateway[n] && m == 1) { gw = " [gateway]" }
			split(ms[m], mi, SUBSEP)
 			print "#\t\t" mi[1], mi[2] gw
 		}
 		print "#"
	eprint

	print "# Creating namespaces"
	for (m in machines) {
		print "mkns", m
	}
	print

	print "# Creating Layer 2"
	for (n in networks) {
		nm = split(networks[n], ms, "\n")
		split(ms[1], ms1, SUBSEP)
		port[ms1[1]]=0

		if (nm > 2) {
			ports = ""
			for (m=2; m <= nm; m++) {
				split(ms[m], mi, SUBSEP)
				ports = ports " " "port"port[ms1[1]]
				print "mkveth", ms1[1], "port"port[ms1[1]]++, mi[1], "eth"eth[mi[1]]++
			}
			print "mkbridge", ms1[1], "eth"eth[ms1[1]]++, ports
		}
		# No need to bridge
		else if (nm == 2) {
			split(ms[2], ms2, SUBSEP)
			print "mkveth", ms1[1], "eth"eth[ms1[1]]++, ms2[1], "eth"eth[ms2[1]]++
		}
		print
	}

	# reseting eth[machines]
	delete eth

	print "# Creating Layer 3"
	print "## Setting IPs"
	for (n in networks) {
		mask = substr(n, index(n, "/"))
		nm = split(networks[n], ms, "\n")
		for (m=1; m <= nm; m++) {
			split(ms[m], mi, SUBSEP)
			print "setip", mi[1], "eth"eth[mi[1]]++, mi[2] mask
		}
		print
	}

	print "## Routing to gateway"
	for (n in networks) {
		if (!gateway[n])
			continue

		nm = split(networks[n], ms, "\n")
		split(ms[1], ms1, SUBSEP)
		for (m=2; m <= nm; m++) {
			split(ms[m], mi, SUBSEP)
			print "setroute", mi[1], "default", ms1[2]
		}
		print
	}
}
