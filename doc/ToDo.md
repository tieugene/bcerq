# ToDo

## 210405:

+ update scripts
+ update doc
- vacuumdb [-h ...] -U btcuser -Fqz btcdb
- CREATE _UNLOGGED_ txo ... (250k: t-15%)
- _test_400.sh (&le; 2016-02-25)
- test xload indexed
- xload into separate script
- Partial xload:
  - all/1y/6m/3m
  - all/till/from/in

## FixMe:

- query.stat
  - tables (simple list)
  - indexed/indices
  - rec counts
  - db size: `SELECT pg_size_pretty(pg_database_size('dbname'));`
- bce2/bceby:
  - timestamp w/o `'`
  - hashes w/o `'`

## Enhancements:

- mk txo as temporary/stored proc
- Try: read-only DB user
- disable journal on import
- use [un]zstd for [un]copress:
  - pigz 1698358803 bytes 13.5" > 792249968
  - zstd 12.7 > 785978602 (.zst)
  - unpigz: 6.6", unstd: 2.2"

## Future:

- Try: tx.hash = NUMBER
- merge impex+dbctl=...
- bcerq.py &rArr; bcerq.sh (bash (env, eval), envsubst, m4, sed, perl)

## Updates

- test `COPY` into non-empty table
- UPDATE vs DELETE+COPY/INSERT
