#!/usr/bin/env python3
"""
Join vins and vouts.
Input - zstded sorted vouts and vins.
Output - stdout (t_id, n, money, a_id, t_id_in)
"""

import gzip
import sys


def main(vouts_fn: str):
    io = ii = oo = oi = 0
    with gzip.open(vouts_fn, "rt") as o_f, sys.stdin as i_f:
        o = o_f.readline().rstrip("\n")
        i = i_f.readline().rstrip("\n")
        if i:
            ii += 1
            il = i.split("\t")
        while o:
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
    res = (io - ii == oo) and io == (oo + oi)
    print("Summary: %s (vouts=%d, vins=%d, utxo=%d, stxo=%d)" % ("OK" if res else "ERR", io, ii, oo, oi),
          file=sys.stderr)


if __name__ == '__main__':
    if len(sys.argv) != 2:
        print("Usage: zstdcat vins.txt.zst | %s vouts.txt.zst [> data.txt]" % sys.argv[0])
    else:
        main(sys.argv[1])
