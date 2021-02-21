# ToDo

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

- Test: read-only DB user
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
