# Readme
BitCoin Export ReQuests - explore BTC blockchain using SQL DB.

This is set of applications to import BTC blockchain into SQL DB and process them:

- Maintaining [database server](doc/DBS.md)
- Maintaining [database](doc/DB.md) (dbctl/)
- [Import](doc/Import.md) data from bcepy/bce2 outputs (import/)
- or [conver](doc/Convert.md) data from Full to Short DB (convert/)
- Check and test loaded DB (test/)
- Make [queries](doc/BCERQ.md) (query/)
- misc: [TODO](TODO.md) list, [notes](doc/NOTES.md)

## Requirements

- python3
- python3-psycopg2/python3-mysqlconnector
- CLI utils: gawk, sed, pigz/unpigz, tail/head