#!/usr/bin/env python3
"""
TODO: load templates
"""

import argparse
import datetime
import json
import os
import sys
from pathlib import Path
from string import Template

import psycopg2

# consts
TPL_DIR = "sql"
OPTS_DICT = {
    "DATE0": "fromdate",
    "DATE1": "todate",
    "NUM": "num"
}


# static
class Opts(object):
    dbhost = 'localhost'
    dbport = 5432
    dbname = None
    dbuser = None
    dbpass = None
    date0 = None
    date1 = None
    num = 25


TplFactory = dict()  # templates factory: cmd: fname, note, required, output, tpl_body


# other

def eprint(s: str):
    print(s, file=sys.stderr)


def do_this(cmd: str):
    # 1. load template
    # print(Opts.date0)
    tpl = Template(TplFactory[cmd]['tpl'])
    # 2. process args
    args = {
        "DATE0": Opts.date0,
        "DATE1": Opts.date1,
        "NUM": Opts.num,
    }
    # 3. prepare request
    request = tpl.substitute(args)
    # 4. exec request
    # print((Opts.dbhost, Opts.dbname, Opts.dbuser, Opts.dbpass))
    conn = psycopg2.connect(host=Opts.dbhost, dbname=Opts.dbname, user=Opts.dbuser, password=Opts.dbpass)
    with conn:
        with conn.cursor() as cursor:
            cursor.execute(request)
            # 5. show result
            for rec in cursor:
                print(rec)
    # 6. exit
    conn.close()


def init_cli():
    """
    Handle CLI
    TODO: print SQL only (dummy mode)
    """
    parser = argparse.ArgumentParser(description='BCE request.')
    parser.add_argument('cmd', type=str, help="Command ('list' to list all available")
    parser.add_argument('-H', '--host', type=str, default='localhost',
                        help='From date')
    parser.add_argument('-f', '--fromdate', metavar='yyyy-mm-dd', type=datetime.date.fromisoformat,
                        help='From date')
    parser.add_argument('-t', '--todate', metavar='yyyy-mm-dd', type=datetime.date.fromisoformat,
                        help='To date')
    parser.add_argument('-n', '--num', metavar='n', type=int, default=25,
                        help='Records to return (default=1)')
    parser.add_argument('-o', '--outfile', metavar='<filename>', type=str, nargs=1,
                        help='Output file name')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='Debug (default=false)')
    return parser


def init_tpls():
    """
    Load all query templates
    :return:
    """
    for fname in os.listdir(TPL_DIR):
        with open(os.path.join(TPL_DIR, fname)) as f:
            tpl = f.read()
        header = ""
        for line in tpl.split("\n"):
            if line.startswith("-- "):
                header += line[3:]
            else:
                break
        # print(header)
        opts = json.loads(header)
        # print(opts)
        TplFactory[opts["name"]] = dict(
            fname=fname,
            note=opts["note"],
            required=opts["required"],
            out=opts["output"],
            tpl=tpl
        )
    # print(TplFactory)


def main():
    """
    CLI commands/options handler.
    TODO: .pgpass, plugins
    """
    # 1. cli
    parser = init_cli()
    args = parser.parse_args()
    Opts.dbhost = args.host
    Opts.date0 = args.fromdate
    Opts.date1 = args.todate
    # FIXME: todate >= fromdate
    Opts.num = args.num
    # 2. templates/commands
    init_tpls()
    if args.cmd == "list":
        print("= Commands: =")
        for k, v in TplFactory.items():
            print("{}: {}".format(k, v["note"]))
        return
    elif args.cmd not in TplFactory:
        eprint("Bad command '{}'. Use 'list' for help.".format(args.cmd))
        return
    # check CLI #2 - required args
    req_ok = True
    for req in TplFactory[args.cmd]['required']:
        req_opt = OPTS_DICT[req]
        if not vars(args)[req_opt]:
            print("Option '{}' required.".format(req_opt))
            req_ok = False
    if not req_ok:
        return
    # 3. ~/.pgpass
    pgpass = Path.home().joinpath('.pgpass')
    if not os.path.isfile(pgpass):
        eprint("Cannot find file ~/.pgpass")
        return
    with open(pgpass) as f:
        for line in f.readlines():
            part = line.rstrip().split(':')
            if part[0] == Opts.dbhost:
                Opts.dbport = int(part[1])
                Opts.dbname = part[2]
                Opts.dbuser = part[3]
                Opts.dbpass = part[4]
                break
    # 4. go
    do_this(args.cmd)
    # parser.print_help()
    # print(args.fromdate)
    # return walk(ldir, ofile, args.num, args.verbose)


if __name__ == '__main__':
    main()
