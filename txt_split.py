#!/usr/bin/env python3
"""
Split bcepy/bce2 output into pieces.
Input: stdin.
Output: start..end.txt.zst (bonus: bkno.txt.zst on one bk).
"""

import os
import re
import sys
import argparse
import zstandard as zstd

# CLI
frombk: int
num: int
by: int
outdir: int
verbose: bool


def vprint(s: str):
    if verbose:
        eprint(s)


def eprint(s: str):
    print(s, file=sys.stderr)


def init_cli():
    """
    Handle CLI
    """
    parser = argparse.ArgumentParser(description="'Split bce2's output into pieces by blocks.",
                                     epilog="Note: processed blocks: frombk..frombk+num*by-1,\n"
                                            "e.g. -f 10 -n 3 -b 2 == 10..15 (10-11, 12-13, 14-15)")
    parser.add_argument('-f', '--from', dest="frombk", metavar='n', type=int, default=0, help='Start bk (default=0)')
    parser.add_argument('-n', '--num', metavar='n', type=int, default=1, help='Parts number (default=1)')
    parser.add_argument('-b', '--by', metavar='n', type=int, default=1, help='Part size, bk (default=1)')
    parser.add_argument('-o', '--outdir', metavar='path', type=str, default='.', help='Output dir (default=\'.\')')
    parser.add_argument('-v', '--verbose', action='store_true', help='Debug (default=false)')
    return parser


def main():
    global frombk, num, by, outdir, verbose
    parser = init_cli()
    args = parser.parse_args()
    if sys.stdin.isatty():
        eprint("No data in <stdin>.")
        parser.print_help()
        return 1
    frombk, num, by, outdir, verbose = args.frombk, args.num, args.by, args.outdir, args.verbose
    isbk = re.compile(r"^b\t(\d{1,6})\t")
    skip = True
    nextpart = frombk
    cctx = zstd.ZstdCompressor()
    compressor = None
    o_f = None
    for line in sys.stdin:
        m = isbk.match(line)
        if not m:       # not bk
            if skip:
                continue
        else:           # bk
            bk = int(m.group(1))
            if skip:
                if bk < frombk:
                    continue
                vprint(f"started: {bk}")
                skip = False
            if bk >= nextpart:
                if o_f:
                    if compressor:
                        compressor.flush()
                        compressor.close()
                    o_f.close()
                num -= 1
                if num < 0:
                    vprint(f"ended: {bk}")
                    break
                nextpart += by
                vprint(f"num={num}, nextpart={nextpart}")
                filename = "%06d.txt.zst" % bk if by == 1 else "%06d-%06d.txt.zst" % (bk, nextpart-1)
                o_f = open(os.path.join(outdir, filename), "wb")
                compressor = cctx.stream_writer(o_f)
        if compressor:
            compressor.write(line.encode('utf-8'))
    if o_f:
        if compressor:
            compressor.flush()
            compressor.close()
        o_f.close()


if __name__ == '__main__':
    main()
