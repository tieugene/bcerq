#!/usr/bin/env python3
"""
Tool to [re]load txo table.
Note: CLI must be B4 main
TODO: common functions into common.py
Chk row exist:
select exists (select 1 from txo);
select exists (select * from txo);
select 1 where exists (select * from txo);
"""

import argparse
from common import *

SQL_From = "AND ((date1 >= '{}') OR (date1 IS NULL)) "  # date1
SQL_UpTo = "AND (bk.datime <= '{}')"    # date0


def init_cli():
    """
    Handle CLI
    TODO: print SQL only (dummy mode)
    """
    parser = argparse.ArgumentParser(description='BCE xload.')
    parser.add_argument('-H', '--host', type=str,
                        help='Host to connect.')
    parser.add_argument('-f', '--from', dest="fromdate", metavar='date', type=datetime.date.fromisoformat,
                        help='From date (yyyy-mm-dd).')
    parser.add_argument('-t', '--to', dest="todate", metavar='date', type=datetime.date.fromisoformat,
                        help='To date (yyyy-mm-dd).')
    # parser.add_argument('-f', '--force', action='store_true',
    #                    help='Force reload (default=false).')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='Debug (default=false).')
    return parser


def load_cli():
    parser = init_cli()
    args = parser.parse_args()
    if args.fromdate and args.todate and args.fromdate > args.todate:
        eprint("Starting date '{}' > ending date '{}'.".format(args.fromdate, args.todate))
        sys.exit(1)
    if args.host:
        Opts.dbhost = args.host
    if args.fromdate:
        Opts.date0 = args.fromdate
    if args.todate:
        Opts.date1 = args.todate
    Opts.verbose = args.verbose


def main():
    """
    Main module
    :return: None
    1. chk txo exists
    2. chk txo idx
    3. chk exist date0, date1
    """
    load_cfg()
    load_cli()
    load_pgpass()
    # 2. templates/commands
    vprint(f"Xload from {Opts.date0} to {Opts.date1}")
    cond = SQL_From.format(Opts.date0) if Opts.date0 else ""
    if Opts.date1:
        cond += SQL_UpTo.format(Opts.date1)
    with open(os.path.join(BASE_DIR, "sql", "xload.sql"), "rt") as tpfile:
        sql = tpfile.read().format(cond)
        print(sql)


if __name__ == '__main__':
    main()
