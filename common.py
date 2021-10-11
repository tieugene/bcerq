"""
Common py items
"""

import configparser
import os
import sys
from pathlib import Path

CFG_FILE_NAME = "bcerq.conf"
CFG_MAIN_SECT = "DEFAULT"
BASE_DIR = os.path.dirname(os.path.abspath(__file__))


class Opts(object):
    dbhost = None
    dbport = 5432  # ? old
    dbname = None
    dbuser = None
    dbpass = None
    # query args
    verbose = False
    date0 = None
    date1 = None


def eprint(s: str):
    print(s, file=sys.stderr)


def vprint(s: str):
    """
    Prints message on verbosity
    :param s: message
    :return: None
    """
    if Opts.verbose:
        eprint(s)

def load_cfg():
    """
    Load defaults from config file.
    :return:
    TODO: use user:pass@host/dbname?engine
    """
    def __inner(cfg_path: str):
        if not os.path.exists(cfg_path):
            return
        config = configparser.ConfigParser()
        # config.read(cfg_real_path)
        config.read_string("[{}]\n{}".format(CFG_MAIN_SECT, open(cfg_path, "rt").read()))
        config_default = config[CFG_MAIN_SECT]
        Opts.dbhost = config_default.get('dbhost')
        Opts.dbname = config_default.get('dbname')
        Opts.dbuser = config_default.get('dbuser')
        Opts.dbpass = config_default.get('dbpass')
    __inner('/etc/bce/'+CFG_FILE_NAME)
    __inner(os.path.expanduser('~/.'+CFG_FILE_NAME))


def load_pgpass():
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
