# Readme
BitCoin Export ReQuests - explore BTC blockchain using [RDB](https://en.wikipedia.org/wiki/Relational_database).
Distributed under GPL 3.0 [license](LICENSE).

This is set of applications to import BTC blockchain into SQL RDB and process them:

- [x]Maintaining [database server](doc/DBS.md)
- [ ]Maintaining [database](doc/DB.md) (dbctl/)
- [ ][Import](doc/Import.md) data from bcepy/bce2 outputs ([code](import/))
- [ ]or [conver](doc/Convert.md) data from Full DB to Midi or Tiny ([code](convert/))
- [ ]Check and test loaded DB (test/)
- [ ]Make [queries](doc/BCERQ.md) ([code](query/))
- [ ]misc: [TODO](doc/TODO.md), [notes](doc/NOTES.md), [statistics](doc/Stat.md)

## Requirements

- python3
- python3 RDB driver:
  - PosgreSQL: python3-psycopg2
  - MySQL/MariaDB: python3-mysql[client] (Linux)/mysql-connector-python3
- RDB CLI client: psql/mysql~~/sqlite~~
- CLI utils: gawk, sed, pigz/unpigz, tail/head

## misc

- 