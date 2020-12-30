#!/usr/bin/env python3
"""
TODO: load templates
"""

import argparse
import configparser
import datetime
import decimal
import json
import os
import sys
import time
from pathlib import Path
from string import Template

import psycopg2

# consts
TPL_DIR = "t"
OPTS_DICT = {
    "DATE0": "fromdate",
    "DATE1": "todate",
    "NUM": "num",
    "ALIST": "alist",
}


# static
class Opts(object):
    dbscheme = None     # ? new
    dbback = None       # ? new
    dbhost = None
    dbport = 5432       # ? old
    dbname = None
    dbuser = None
    dbpass = None
    # query args
    date0 = None
    date1 = None
    num = None
    alist = list()
    # misc
    sep = None
    verbose = False


TplFactory = dict()  # templates factory: cmd: fname, note, required, output, tpl_body


# other

def eprint(s: str):
    print(s, file=sys.stderr)


def load_cfg():
    """
    Load defaults from config file.
    :return:
    TODO: use user:pass@host/dbname?engine
    """
    cfg_real_path = os.path.expanduser(CFG_FILE_NAME)
    if not os.path.exists(cfg_real_path):
        return
    config = configparser.ConfigParser()
    # config.read(cfg_real_path)
    config.read_string("[{}]\n{}".format(CFG_MAIN_SECT, open(cfg_real_path, "rt").read()))
    config_default = config[CFG_MAIN_SECT]
    Opts.dbscheme = config_default.get('dbscheme')
    Opts.dbback = config_default.get('dbengine')
    Opts.dbhost = config_default.get('dbhost')
    Opts.dbname = config_default.get('dbname')
    Opts.dbuser = config_default.get('dbuser')
    Opts.dbpass = config_default.get('dbpass')


def init_cli():
    """
    Handle CLI
    TODO: print SQL only (dummy mode)
    """
    parser = argparse.ArgumentParser(
        description='BCE request.',
        epilog="NOTE: address list must be column of ints.")
    parser.add_argument('cmd', type=str, help="Command ('list' to list all available).")
    parser.add_argument('-H', '--host', type=str, default='localhost',
                        help='Host to connect.')
    parser.add_argument('-f', '--from', dest="fromdate", metavar='date', type=datetime.date.fromisoformat,
                        help='From date (yyyy-mm-dd).')
    parser.add_argument('-t', '--to', dest="todate", metavar='date', type=datetime.date.fromisoformat,
                        help='To date (yyyy-mm-dd).')
    parser.add_argument('-n', '--num', type=int,
                        help='Records to return / min satoshi limit.')
    parser.add_argument('-a', '--alist', type=str,
                        help="Address list (use '-' for stdin; see 'NOTE:').")
    parser.add_argument('-s', '--sep', type=str, default="\t",
                        help="Output fields separator (default=<TAB>).")
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='Debug (default=false).')
#    parser.add_argument('-o', '--out', metavar='file', type=str, nargs=1,
#                        help='Output file name (NA).')
    return parser


def init_templates():
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
            header=opts["header"],
            out=opts["output"],
            tpl=tpl
        )
    # print(TplFactory)


def load_alist(f):
    """
    Load Opts.alist from opened file
    :param f: File to load
    :return: None
    """
    # Opts.alist = [s.rstrip() for s in f.readlines()]
    Opts.alist = list()
    for line in f.readlines():
        if line[0].isdigit():
            Opts.alist.append(line.split()[0])


def do_this(cmd: str):
    # 1. load template
    # print(Opts.date0)
    tpl = TplFactory[cmd]
    tpl_str = Template(tpl['tpl'])
    # 2. process args
    args = {
        "DATE0": Opts.date0,
        "DATE1": Opts.date1,
        "NUM": Opts.num,
        "ALIST": ",".join(Opts.alist),
    }
    # 3. prepare request
    request = tpl_str.substitute(args)
    # 4. exec request
    # print((Opts.dbhost, Opts.dbname, Opts.dbuser, Opts.dbpass))
    conn = psycopg2.connect(host=Opts.dbhost, dbname=Opts.dbname, user=Opts.dbuser, password=Opts.dbpass)
    with conn:
        with conn.cursor() as cursor:
            if Opts.verbose:
                print("= <SQL> =\n{}\n= </SQL> =".format(request))
            t0 = time.time()
            cursor.execute(request)
            eprint("Timer, s: {}".format(int(time.time() - t0)))
            # 5. show result
            print(Opts.sep.join(['"' + s + '"' for s in tpl['header']]))
            for rec in cursor:
                # int>int, str>'str', Decimal>int?
                rec_str_array = list()
                for f in rec:
                    if isinstance(f, int):
                        rec_str_array.append(str(f))
                    elif isinstance(f, str):
                        rec_str_array.append('"{}"'.format(f))
                    elif isinstance(f, decimal.Decimal):
                        rec_str_array.append(str(int(f)))
                    elif f is None:
                        rec_str_array.append('')
                    else:
                        eprint("Unknown type: {}:{}".format(f, type(f)))
                print(Opts.sep.join(rec_str_array))
                # print(rec)
    # 6. exit
    conn.close()


def main():
    """
    CLI commands/options handler.
    TODO: .pgpass, plugins
    """
    # 1. cli
    load_cfg()
    parser = init_cli()
    args = parser.parse_args()
    if args.fromdate and args.todate and args.fromdate > args.todate:
        eprint("Starting date '{}' > ending date '{}'.".format(args.fromdate, args.todate))
        return
    if args.host:
        Opts.dbhost = args.host
    if args.fromdate:
        Opts.date0 = args.fromdate
    if args.todate:
        Opts.date1 = args.todate
    if args.num:
        Opts.num = args.num
    Opts.sep = args.sep
    Opts.verbose = args.verbose
    if args.alist:
        if args.alist == '-':
            f = sys.stdin
        else:
            f = open(args.alist, "rt")
        with f:
            load_alist(f)
    # 2. templates/commands
    init_templates()
    if args.cmd == "list":
        print("= Commands: =")
        for k in sorted(TplFactory):
            print("{}: {}".format(k, TplFactory[k]["note"]))
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
