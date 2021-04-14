#!/usr/bin/env python3
"""
Converts txt (bce2 output) into SQL strings to update SQL DB.
Pipeline:
unpigz -c <src1.txt.gz> <src2.txt.gz>... |
txt2sql.py |
(wrap in 'LOCK ...; BEGIN; ... COMMIT;) |
psql -c btcdb btcuser
RTFM (wrap): https://stackoverflow.com/questions/15112882/how-to-wrap-piped-input-to-stdout-in-a-bash-script
`echo 'BEFORE' $(cat) 'AFTER'`

Sample:
b       170     '2009-01-12 06:30:25'   '00000000d1145790a8694403d4063f323d499e655c83426834d4ce2f8dd4a2ee'
t       170     170     b1fea52486ce0c62bb442b530a3f0132b826c74e473d1f2c220bfa78111c5082
a       170     "1PSSGeFHDnKNxiEyFrD1wcEaHr9hrQDDWc"    1
o       170     0       5000000000      170
t       171     170     f4184fc596403b9d638783cf57adfe4c75c605f6356fbc91338530e9831e9e16
i       9       0       171
a       171     "1Q2TWHE3GMdB6BZKafqwxXtWAWgFt5Jvm3"    1
o       171     0       1000000000      171
o       171     1       4000000000      9

TODO: handle addressless ^o (replace with NULL):
o       97258   1       1000000 \N
"""

import sys
import re

is_aless = re.compile(r"^o\t\d+\t\d+\t\d+\t\\N$")
template = {
    'a': "INSERT INTO addr (id, name, qty) VALUES ({}, {}, {});",
    'b': "INSERT INTO bk (id, datime) VALUES ({}, {});",
    't': "INSERT INTO tx (id, b_id, hash) VALUES ({}, {}, {});",
    'o': "INSERT INTO vout (t_id, n, money, a_id) VALUES ({}, {}, {}, {});",
    'i': "UPDATE vout SET t_id_in={} WHERE t_id={} AND n={};",
}


def cb_i(s: list) -> str:
    """
    Callback for VIn
    :param s: split line
    :return: SQL 'UPDATE'
    """
    pass


def cb_o(s: list) -> str:
    """
    Callback for VIn
    :param s: split line
    :return: SQL 'INSERT'
    """
    pass


def main():
    for line in sys.stdin:
        if is_aless.match(line):
            line = line.replace("\\N", "NULL")
        beg = line[0]
        print(template[beg](line.split('\t')[1:]), end='')


if __name__ == '__main__':
    if sys.stdin.isatty():  # stdin is empty
        print(f"Usage: unpigz -c block.txt.gz | {sys.argv[0]} [> outfile.sql]", file=sys.stderr)
    else:
        main()
