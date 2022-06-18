#!/usr/bin/env python3
"""
Query by TZ_220606
"""
import sys
from datetime import date, datetime
import time
import psycopg2
from _opts import Opts


HELP = \
    "Usage: %s <date> <rid> [limit]\n" \
    "Options:\n" \
    "  date - date to start from\n" \
    "  rid - address range id (1..11)\n" \
    "  limit - addresses to get (defailt=all)"
RID = (
    (1, 10**5),
    (10**5 + 1, 10**6),
    (10**6 + 1, 10**7),
    (10**7 + 1, 10**8),
    (10**8 + 1, 10**9),
    (10**9 + 1, 10**10),
    (10**10 + 1, 10**11),
    (10**11 + 1, 10**12),
    (10**12 + 1, 10**13),
    (10**13 + 1, 10**14),
    (10**14 + 1, 22 * 10**14)  # 21 M₿ is hardcoded limit
)
MAX_ADDRS = 10**6
QUERY = "SELECT * FROM _q_220606(__get_date_tx_min('%s'), %d, %d, %d) ORDER BY a_id, dt0, dt1"


def __query(d: date, m_min: int, m_max: int, lim: int):
    """Query DB"""
    with psycopg2.connect(host=Opts.dbhost, dbname=Opts.dbname, user=Opts.dbuser, password=Opts.dbpass) as conn:
        with conn.cursor() as cursor:
            q = QUERY % (d.isoformat(), m_min, m_max, lim)
            # q = open('/Users/eugene/VCS/my/GIT/bcerq/sql/q1a/220606/step_5.sql', 'rt').read()
            cursor.execute(q)
            for rec in cursor:
                yield rec
        # conn.close()


def __out_vout(d: date, row: list, fs: str):
    """Print one vout
    :param d: date from
    :param row: [money, d0, d1]
    """

    def __prn(_fs: str, m: int, _d: datetime):
        print("%s{%.3f,%s}" % (_fs, m/100000000, _d.strftime("%y%m%d,%H:%M")), end='')

    if row[1].date() >= d:
        __prn(fs, row[0], row[1])
        fs = ','
    if row[2] is not None:
        __prn(fs, -row[0], row[2])


def doit(d: date, m_min: int, m_max: int, lim: int):
    """Print result"""
    t0 = time.time()
    addr = None
    rs = ''  # record separator (between addrs)
    fs = ''  # field separator (between vouts)
    for row in __query(d, m_min, m_max, lim):
        a_id = row[0]
        if a_id != addr:
            print("%s#%s{" % (rs, row[1]), end='')
            addr = a_id
            if not rs:
                rs = "},\n"
            fs = ''
        elif not fs:
            fs = ','
        __out_vout(d, row[2:], fs)
    print("}")
    t1 = time.time()
    print(f"Time: {t1-t0}", file=sys.stderr)


def cli(argv: list[str]) -> tuple:
    """Process CLI"""
    if len(argv) not in {3, 4}:
        print(HELP % argv[0], file=sys.stderr)
        sys.exit()
    return\
        date.fromisoformat(argv[1]),\
        *RID[int(argv[2])-1],\
        int(argv[3]) if len(argv) == 4 else MAX_ADDRS


def main():
    opts = cli(sys.argv)
    doit(*opts)


if __name__ == '__main__':
    main()
