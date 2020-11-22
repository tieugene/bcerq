# BCERQ

## Prerequisitions

- filled out ~/.pgpass
- filled out ~/.bcerqrc

Example of ~/.bcerqrc:

```
DBHOST=192.168.0.33
DBNAME=btcdatabase
DBUSER=btcuser
```

Where:

- DBHOST: host where PostgreSQL is running (can be `/tmp/` to use socket)
- DBNAME: PostgreSQL database at this host
- DBUSER: PostgreSQL user has permision to query database above

## Usage

`./bcerq.py <options> <command>`

Options:

- -H/--host
- -f/--from [date] - starting date
- -t/--to [date] - end date
- -n/--num [int] - limit (qty/btc/%)
- -a/--alist - address list (filename or '-' for stdin)

Database name and DB user not required - programm get them from ~/.pgpass relating to `hostname`.

## TODO:

- comment out alist
- ~/.bcerqrc, ~/.pgpass
