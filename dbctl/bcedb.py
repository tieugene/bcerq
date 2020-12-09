#!/usr/bin/env python3
"""
Tool to manipulate bce SQL database.
TODO: PGSQL:
- trunc cascade (t, b)
- unidx cascade (t, b)
"""

import argparse
import configparser
import os
import sys
from enum import Enum

# const
CFG_FILE_NAME = "~/.bcerq.ini"
CFG_MAIN_SECT = "DEFAULT"
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SCHEME_DIR = None


class DbSchemeType(Enum):
    FULL = 'f'  # full
    MIDI = 'm'  # midi
    TINY = 't'  # tiny


class DbEngineType(Enum):
    MYSQL = 'm'  # mysql
    PGSQL = 'p'  # postgresql


class DbEngMySQL(object):

    def __init__(self):
        self.db_conn = None
        self.db_cursor = None

    def load_cfg(self):
        """
        Load and parse ~/.my.cnf
        :return:
        """
        config = configparser.ConfigParser()
        config.read('~/my.cfg')

    def open(self) -> bool:
        import mysql.connector
        # dbconn = mysql.connector.connect(database=Opts.dbname, user=Opts.dbuser, password=Opts.dbpass)
        self.db_conn = mysql.connector.connect(host=Opts.dbhost, database=Opts.dbname, user=Opts.dbuser,
                                               password=Opts.dbpass)
        self.db_cursor = self.db_conn.cursor()
        return True

    def exec_sql(self, sql_string: str) -> bool:
        """
        :param sql_string:
        :return: True if OK
        """
        message(sql_string)
        ret_value = False
        response = []
        try:
            response = self.db_cursor.execute(sql_string, multi=True)
            ret_value = True
        except Exception as err:
            eprint("Error exec '{}': {}".format(sql_string, err))
        for result in response:
            if result.with_rows:
                for row in result.fetchall():
                    print(row)
        return ret_value

    def close(self):
        self.db_cursor.close()
        self.db_conn.close()


class DbEngPGSQL(object):

    def __init__(self):
        self.db_conn = None
        self.db_cursor = None

    def load_cfg(self):
        """
        Load and parse ~/.pgpass
        :return:
        """
        from pathlib import Path
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

    def open(self):
        import psycopg2
        self.db_conn = psycopg2.connect(host=Opts.dbhost, dbname=Opts.dbname, user=Opts.dbuser, password=Opts.dbpass)
        self.db_conn.autocommit = True
        self.db_cursor = self.db_conn.cursor()
        return True

    def exec_sql(self, sql_string: str) -> bool:
        """
        FIXME: vacuum out from commit
        :param sql_string:
        :return: True if OK
        """
        message(sql_string)
        ret_value = True
        self.db_cursor.execute(sql_string)
        # self.db_conn.commit()
        if self.db_cursor.rowcount > 0:
            for row in self.db_cursor.fetchall():
                print(row)
        return ret_value

    def close(self):
        self.db_cursor.close()
        self.db_conn.close()


class Command(Enum):
    # table specific, engine [in]dependent
    CREATE = 'create'
    INDEX = 'idx'
    UNINDEX = 'unidx'
    # table independent, engine specific
    WASH = 'wash'  # VACUUM/OPTIMIZE
    SHOW = 'show'  # [SHOW TABLES;] SHOW COLUMNS FROM <table>; SELECT COUNT (*) FROM <table>;
    # table independent, engine independent
    DROP = 'drop'  # delete, zap
    TRUNC = 'trunc'
    # not DB
    LIST = 'list'


cmd_help = """Commands:
---------
create\t- create table
idx\t- create indices and constraints
unidx\t- drop indices and constraints
show\t- show table info
wash\t- wash up table (vacuum/optimize)
trunc\t- delete all data
drop\t- drop table
list\t- this help
"""

val_help = """Values:
-------
Debug:\t{}
Scheme:\t{}
Engine:\t{}
Host:\t{}
DB:\t{}
User:\t{}
Pass:\t{}
Tables:\t{}
"""


# static
class Opts(object):
    dbscheme = None  # mandatory; DbSchemeType.FULL
    dbback = None  # mandatory; DbEngineType.PGSQL
    dbhost = None  # None=socket
    dbname = None
    dbuser = None
    dbpass = None
    verbose = False
    # var


def eprint(s: str):
    print(s, file=sys.stderr)


def message(s: str):
    if Opts.verbose:
        eprint(s)


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
    Handle CLI.
    TODO: handle table type (short and full)
    """
    parser = argparse.ArgumentParser(description='BCE DB manipulation.')
    parser.add_argument('cmd', type=Command, metavar="cmd", choices=Command,
                        help="Command ('list' to list all available commands and current defaults).")
    parser.add_argument('table', type=str, nargs='?', help="Table (default=all).")
    parser.add_argument('-s', '--scheme', metavar="SCHEME", type=DbSchemeType, choices=DbSchemeType,
                        help='Database scheme (f[ull]/m[idi]/t[iny]).')
    parser.add_argument('-b', '--backend', metavar="BACKEND", type=DbEngineType, choices=DbEngineType,
                        help='SQL backend (p[ostgresql]/m[ariadb]).')
    parser.add_argument('-H', '--host', type=str,
                        help='Database host (default=socket).')
    parser.add_argument('-d', '--dbname', type=str,
                        help='Database name.')
    parser.add_argument('-u', '--user', type=str,
                        help='Database user.')
    parser.add_argument('-p', '--password', type=str,
                        help='Database password.')
    parser.add_argument('-v', '--verbose', action='store_true',
                        help='Debug (default=false).')
    parser.add_argument('-l', '--log', action='store_true',
                        help='Log to file (default=false).')
    return parser


def prn_help(tables: set):
    print(cmd_help)
    print(val_help.format(
        Opts.verbose,
        Opts.dbscheme,
        Opts.dbback,
        Opts.dbhost,
        Opts.dbname,
        Opts.dbuser,
        Opts.dbpass,
        tables
    ))


def do_this(db_connector: object, cmd: Command, table: str = None) -> int:
    """
    Execute command
    :param db_connector: DB connector
    :param cmd: command to exec
    :param table: table name 1st character
    :return:
    """
    # print("{} {}".format(cmd, table))
    if not table:
        eprint("Bulk operations not implemented yet.")
        return 1
    path_table = os.path.join(SCHEME_DIR, table)
    cmd_file_name = cmd.value[0] + '.sql'
    sql_found = False
    # main script
    # TODO: merge multiple SQLs
    path_cmd = os.path.join(path_table, cmd_file_name)
    if os.path.isfile(path_cmd):
        sql_found = True
        with open(path_cmd, "rt") as f:
            message("Run '{}".format(path_cmd))
            if not db_connector.exec_sql(f.read()):
                return 1
    # engine-specific script
    path_cmd = os.path.join(path_table, Opts.dbback, cmd_file_name)
    if os.path.isfile(path_cmd):
        sql_found = True
        with open(path_cmd, "rt") as f:
            message("Run '{}".format(path_cmd))
            if not db_connector.exec_sql(f.read()):
                return 1
    if not sql_found:
        eprint("'{}' for table '{}' not found".format(cmd_file_name, table))
    return 0


def main() -> int:
    """
    Loading data.
    Order: config => CLI [=> .my.cnf/.pgpass]
    """
    global SCHEME_DIR
    # 1. load cfg
    load_cfg()
    # 2. CLI
    parser = init_cli()
    args = parser.parse_args()
    if args.scheme:
        Opts.dbscheme = args.scheme
    if args.backend:
        Opts.dbback = args.backend
    if args.host:
        Opts.dbhost = args.host
    if args.dbname:
        Opts.dbhost = args.dbname
    if args.user:
        Opts.dbuser = args.user
    if args.password:
        Opts.dbpass = args.password
    Opts.verbose = args.verbose
    # 3. engine cfg
    # 4.1. chk pre-engine options
    message("Check scheme")
    if Opts.dbscheme:
        SCHEME_DIR = os.path.join(BASE_DIR, Opts.dbscheme)
        if not os.path.isdir(SCHEME_DIR):
            eprint("Path '{}' not exists or is not dir".format(SCHEME_DIR))
            return 1
        tables = set(os.listdir(SCHEME_DIR))
        message("Scheme ok")
    else:
        eprint("Scheme not defined")
    # 4.2. db engine
    message("Check DB engine")
    if Opts.dbback:
        if Opts.dbback == DbEngineType.MYSQL.value:
            message("MySQL")
            db_engine = DbEngMySQL()
            message("MySQL created ok")
        elif Opts.dbback == DbEngineType.PGSQL.value:
            message("PgSQL")
            db_engine = DbEngPGSQL()
        else:
            eprint("Backend {} is not implemented yet.".format(Opts.dbback))
        message("DB engine ok")
    else:
        eprint("DB engine is not defined")
    # TODO: db_engine.load_cfg()
    # 4. chk options (table, db conn)
    if args.cmd == Command.LIST:
        prn_help(tables)
        return 0
    else:        # TODO: expand chk
        err_count = 0
        if not Opts.dbscheme:
            err_count += 1
        if not Opts.dbback:
            err_count += 1
        if err_count:
            return 1
    # -- pause?
    # 4.3. table
    if args.table:  # TODO: multiple tables
        if args.table not in tables:
            eprint("Unknown table '{}', usable: {}.".format(args.table, ', '.join(tables)))
            return 1
        path_table = os.path.join(SCHEME_DIR, args.table)
        if not os.path.isdir(path_table):
            eprint("Path '{}' not exists or is not dir".format(path_table))
            return 1
        t2job = [args.table]
    else:   # job all tables
        t2job = list(tables)
        t2job.sort(reverse=(args.cmd.value[0] in 'utd'))
    # 5. go
    retvalue = 0
    if db_engine.open():
        for t in t2job:
            retvalue += do_this(db_engine, args.cmd, t)
        db_engine.close()
    return retvalue


if __name__ == '__main__':
    retvalue = main()
    message("Err" if retvalue else "OK")
    sys.exit(retvalue)
