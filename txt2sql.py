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
FIXME: something wrong with addr.name (json)
TODO: 249329 - multisign
"""

import sys


def cb_o(s: list) -> str:
    end = 'NULL' if s[3] == '\\N' else s[3]
    return f"INSERT INTO vout (t_id, n, money, a_id) VALUES ({s[0]}, {s[1]}, {s[2]}, {end});"


def main():
    template = {
        'a': lambda a: f"INSERT INTO addr (id, name, qty) VALUES ({a[0]}, '{a[1]}', {a[2]});",
        'b': lambda a: f"INSERT INTO bk (id, datime) VALUES ({a[0]}, {a[1]});",
        't': lambda a: f"INSERT INTO tx (id, b_id, hash) VALUES ({a[0]}, {a[1]}, '{a[2]}');",
        'o': lambda a: cb_o(a),
        'i': lambda a: f"UPDATE vout SET t_id_in={a[2]} WHERE t_id={a[0]} AND n={a[1]};",
    }
    for line in sys.stdin:
        s_line = line.rstrip("\n").split('\t')
        out = template[s_line[0]](s_line[1:])
        print(out)


if __name__ == '__main__':
    if sys.stdin.isatty():  # stdin is empty
        print(f"Usage: unpigz -c block.txt.gz | {sys.argv[0]} [> outfile.sql]", file=sys.stderr)
    else:
        main()
