#!/bin/env python3
"""
Join vins and vouts.
Input - gziped sorted vouts and vins.
Output - stdout
"""

import gzip, sys

def main (vouts_fn: str, vins_fn: str):
	io = ii = oo = oi = 0
	with gzip.open(vouts_fn, "rt") as o_f, gzip.open(vins_fn, "rt") as i_f:
		o = o_f.readline().rstrip("\n")
		i = i_f.readline().rstrip("\n")
		if i:
			ii += 1
			il = i.split("\t")
		while (o):
			io += 1
			ol = o.split("\t")
			if (i) and (ol[:2] == il[:2]):
				print("%s\t%s" % (o, il[2]))
				oi += 1
				i = i_f.readline().rstrip("\n")
				if i:
					ii += 1
					il = i.split("\t")
			else:
				print("%s\t\\N" % o)
				oo += 1
			o = o_f.readline().rstrip("\n")
	res = (io-ii == oo) and io == (oo + oi)
	print("Summary: %s (vouts=%d, vins=%d, free=%d, spent=%d)" % ("OK" if res else "ERR", io, ii, oo, oi), file=sys.stderr)

if __name__ == '__main__':
	if len(sys.argv) != 3:
		print("Usage: %s vouts.txt.gz vins.txt.gz [> data.txt]" % sys.argv[0])
	else:
		main(sys.argv[1], sys.argv[2])
