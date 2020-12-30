# Readme

BitCoin Export ReQuests - explore BTC blockchain using [RDB](https://en.wikipedia.org/wiki/Relational_database).
Distributed under GPL 3.0 [license](LICENSE).

This is set of applications to import BTC blockchain into SQL RDB and process them:

- &#9745; [Maintaining database server](doc/DBS.md)
- &#9745; [Maintaining database](doc/DB.md) ([code](dbctl/))
- &#9744; [Import/Export](doc/ImpEx.md) data from bce.py/bce2 or between databases ([code](impex/))
- &#9745; Check and benchmark SQL DB ([code](test/))
- &#9744; [Make queries](doc/BCERQ.md) ([code](query/))
- &#9746; misc:
  - &#9745; [Workflow example](doc/WorkFlow.md)
  - &#9746; [TODO](doc/TODO.md) list
  - &#9746; Misc [notes](doc/NOTES.md)
  - &#9746; [Statistics](doc/Stat.md)
  - &#9745; Config [example](doc/bcerq.ini.sample)

## Requirements

- python3
- python3-psycopg2
- PostgreSQL CLI: psql
- CLI utils: gawk, sed, pigz/unpigz, tail/head
