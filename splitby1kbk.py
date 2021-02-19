#!/usr/bin/env python3
"""
Split bce.py/bce2 output into 1000 blocks pieces.
Input: stdin.
Output: XXX.txt.gz, where XXX is kilo.
"""

import gzip
import os
import re
import sys


def main(outdir: str):
    o_f = None
    isbk = re.compile("^b\t(\d{1,3})000\t")
    # with sys.stdin as i_f:
    with gzip.open("txt/050-100.txt.gz", "rt") as i_f:
        line = i_f.readline()
        while line:
            m = isbk.match(line)
            if m:
                if o_f:
                    o_f.close()
                o_f = gzip.open(os.path.join(outdir, "%03d.txt.gz" % int(m.group(1))), "wt")
            if o_f:
                o_f.write(line)
            line = i_f.readline()
    if o_f:
        o_f.close()


if __name__ == '__main__':
    if sys.stdin.isatty():
        print("Usage: unpigz -c 050-100.txt.gz | {} [outdir]".format(sys.argv[0]), file=sys.stderr)
    else:
        main(sys.argv[1] if len(sys.argv) >= 2 else ".")
