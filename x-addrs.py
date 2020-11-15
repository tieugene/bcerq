#!/usr/bin/env python3
"""
Create intersection of address lists.
- In: 2+ *.csv with columns (a_id, addr, ...) (Note: skip header)
- Out: & of lists
"""

import csv
import sys


def eprint(s: str):
    print(s, file=sys.stderr)


def main():
    if len(sys.argv) < 3:
        eprint("Usage: {} file1.csv file2.csv [file3.csv...]".format(sys.argv[0]))
        return
    # 0. prep
    id_all = set()
    addr = dict()
    for file_name in sys.argv[1:]:
        with open(file_name, "rt") as f:
            # 1. load current csv
            cf = csv.DictReader(f, delimiter="\t")
            id_local = set()
            for row in cf:
                a_id = row['a_id']
                id_local.add(a_id)
                addr[a_id] = row['address']
            # 2. compare
            if id_all:
                id_all &= id_local
            else:
                id_all = id_local
    # 3. output
    for a_id in id_all:
        print("{}\t{}".format(a_id, addr[a_id]))


if __name__ == '__main__':
    main()
