# Readme

BitCoin Export ReQuests - explore BTC blockchain using [RDB](https://en.wikipedia.org/wiki/Relational_database).

## Description

Utilities set to import BTC blockchain data from [bcepy](https://github.com/tieugene/bcepy) or [bce2](https://github.com/tieugene/bce2) output into PostgreSQL DB and query it.

## Requirements

- core utils (`bash`, `gawk`, `sed`, `tail`/`head`, `zstd`/`zstdcat`)
- PostgreSQL CLI client (`psql`)
- python3-psycopg2

## Documentation

- Typical [workflow](doc/WorkFlow.md)
- Maintain [DB server](doc/DBS.md)
- Maintain [DB](doc/DB.md)
- [Import](doc/ImpEx.md) data
- Create [TXO](doc/TXO.md) data
- [Test](doc/Test_DB.md) loaded DB
- Make [queries](doc/BCERQ.md)
- Config [sample](doc/bcerq.ini)
- *[ToDo](doc/ToDo.md) list*
- *Misc [notes](doc/Notes.md)*
- *Misc [tests](doc/tests)*
- *[contrib](doc/Contrib.md) scripts*
- *~~Data [formats](doc/Formats.md)~~*

## Utilities

- [bcedb.sh](bcedb.sh) - Maintain database
- [txt2tsv.sh](txt2tsv.sh) - Convert bcepy/bce2 output into interim [.TSV](https://en.wikipedia.org/wiki/Tab-separated_values) data
  - [join_io.py](join_io.py) - helper for them
- [tsv2db.sh](tsv2db.sh) - Load interim .TSV into SQL DB
- [bcerq.py](bcerq.py) - Make queries to SQL DB
  - [x-addrs.py](x-addrs.py) - helper for them
- [splitby1kbk.py](splitby1kbk.py) - split bce* outs by 1 kbk (kiloblock)
- [test_db.sh](test_db.sh) - DB benchmark

## License

Distributed under GPL 3.0 [license](LICENSE).

## Branches:

- 0.0.1 - old snapshot
- multidb - experimental with switchable DB-engine
- devel - current
- main - stable
