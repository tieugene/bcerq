# BCERQ

Querying SQL DB about BTC.

Each query is one SQL 'string' with parameters and asks txo[+addr] table.

Each query represents as 'command' of bcerq.py.
Mandatory options of 'command' depend on this command itself.

Results printing into stdout.

Prerequisitions: `~/.bcerq.ini`

## Usage

_(use `bcerq.py -h` for help)_

`./bcerq.py <options> <command>`

Options:

- -f *date* - starting date
- -t *date* - end date
- -n *int* - limit (qty/btc/%)
- -a *file* - address list (filename or '-' for stdin)

## Tests:

_(250k, `./bcerq.py … | tee tmp/….tsv`)_

- `-t 2013-06-01 -n 4000000000000 addr_gt`
- `-f 2013-01-01 -t 2013-06-01 -n 20 addr_btc_max`
- `-f 2013-01-01 -t 2013-06-01 -n 20 addr_btc_min`
- `-f 2013-01-01 -t 2013-06-01 -n 20 addr_cnt_max`
- `-f 2013-01-01 -t 2013-06-01 -n 20 addr_cnt_min`
- `-f 2013-01-01 -t 2013-06-01 -n 1 -a alist.txt alist_btc_gt`
- `-f 2013-01-01 -t 2013-06-01 -n 1 -a alist.txt alist_btc_lt`
- `-f 2013-01-01 -t 2013-06-01 -n 1 -a alist.txt alist_cnt_gt`
- `-f 2013-01-01 -t 2013-06-01 -n 1 -a alist.txt alist_cnt_lt`
- `-f 2013-01-01 -t 2013-06-01 -a alist.txt alist_moves`
