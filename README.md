# Readme

BitCoin Export ReQuests - explore BTC blockchain using [RDB](https://en.wikipedia.org/wiki/Relational_database).

Distributed under GPL 3.0 [license](LICENSE).

## Description

This is set of applications to import BTC blockchain from [bcepy](https://github.com/tieugene/bcepy) or [bce2](https://github.com/tieugene/bce2) output into PostgreSQL DB and process them:

- &#9745; [Maintaining database server](doc/DBS.md)
- &#9745; [Maintaining database](doc/DB.md) ([bcedb.sh](bcedb.sh))
- &#9744; [Import](doc/ImpEx.md) data from bcepy/bce2 ([txt2tsv.sh](txt2tsv.sh) and [tsv2db.sh](tsv2db.sh))
- &#9745; Check and benchmark SQL DB ([code](test/))
- &#9744; [Make queries](doc/BCERQ.md) ([bcerq.py](bcerq.py))
- &#9746; misc:
  - &#9745; [Workflow example](doc/WorkFlow.md)
  - &#9746; [TODO](doc/TODO.md) list
  - &#9746; Misc [notes](doc/NOTES.md)
  - &#9746; [Statistics](doc/Stat.md)
  - &#9745; Config [example](doc/bcerq.ini.sample)

## Requirements

- core utils (bash, gawk, sed, pigz/unpigz, tail/head)
- python3
- python3-psycopg2
- PostgreSQL CLI client (psql)

## Content

- [bcedb.sh](bcedb.sh) - Handle database
- [txt2tsv.sh](txt2tsv.sh) - Convert bce.py/bce2 output into interim [.TSV](https://en.wikipedia.org/wiki/Tab-separated_values) data
  - [join_io.py](join_io.py) - helper for them
- [tsv2db.sh](tsv2db.sh) - Load interim .TSV into SQL DB
- [bcerq.py](bcerq.py) - Make queries to SQL DB
  - [x-addrs.py](x-addrs.py) - helper for them
- [doc/](doc/) - Documentation
- [sql/](sql/) - Required for utils above
