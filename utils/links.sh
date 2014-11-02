#!/bin/sh

# Generate data with awk
awk '
BEGIN {
	print "graph G {"
}
/^mkveth/ {
	print "\t", $2, "--", $4 ";"
}
END {
	print "}"
}' $1 | dot -Tpng > $1.png && echo $1.png

