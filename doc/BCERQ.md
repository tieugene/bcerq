# BCERQ

Querying SQL DB about BTC.

Each query is one SQL 'string' with parameters and asks txo[+addr] table.

Each query represents as 'command' of bcerq.py.
Mandatory options of 'command' depend on this command itself.

Prerequisitions: `~/.bcerq.ini`

## Usage

_(use `bcerq.py -h` for help)_

`./bcerq.py <options> <command>`

Options:

- -H/--host
- -f/--from [date] - starting date
- -t/--to [date] - end date
- -n/--num [int] - limit (qty/btc/%)
- -a/--alist - address list (filename or '-' for stdin)

Database name and DB user not required - programm get them from ~/.pgpass relating to `hostname`.

Other options (-f -t -n -a) depend on query itself

## Tests:
_(250k, `./bcerq.py … | tee tmp/….tsv`)_
- 90": `-t 2013-06-01 -n 4000000000000 addr_gt`
- 15": `-n 20 -f 2013-01-01 -t 2013-06-01 addr_btc_max`
- ": `-n 20 -f 2013-01-01 -t 2013-06-01 addr_btc_min`
- ": `-n 20 -f 2013-01-01 -t 2013-06-01 addr_cnt_max`
- ": `-n 20 -f 2013-01-01 -t 2013-06-01 addr_cnt_min`
- ": `-a alist.txt -f 2013-01-01 -t 2013-06-01 -n 1 alist_btc_gt`
- ": `-a alist.txt -f 2013-01-01 -t 2013-06-01 -n 1 alist_btc_lt`
- ": `-a alist.txt -f 2013-01-01 -t 2013-06-01 -n 1 alist_cnt_gt`
- ": `-a alist.txt -f 2013-01-01 -t 2013-06-01 -n 1 alist_cnt_lt`
- ": `-a alist.txt -f 2013-01-01 -t 2013-06-01 alist_moves`
