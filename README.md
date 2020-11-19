# bcerq
BitCoin Export ReQuests - explore BTC blockchain SQL DB.

## Requirements

- python3
- python3-psycopg2
- running PostgrSQL server

## Usage

./bcerq.py <options> <command>

Options:
- H --host
- f --from [date] - starting date
- t --to [date] - end date
- n --num [int] - limit (qty/btc/%)
- a --alist - address list

Database name and DB user not required - programm get them from ~/.pgpass relating to hostname.

## Content

- bcerq.py
- sql:
  - ...
  - ...
_ _sql:
  - ...
  - ...
