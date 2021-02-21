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

## Queiries:
