# ToDo

## 210929:

- [x] SQL seq/tx/bulk_tx: "psql exec -c as single tx"
- [x] contrib/
   - [x] init
      - [x] init_1
      - [x] init_2 (200k): 129/120 (10%)
      - [x] init_3: 65/60 (10%)
      - [x] init_4: by1=114", z=124"
   - [x] aio
- [x] `psql -q -c "$(./xload.py -f 2020-09-29)" btc alex)`

## 210405:

- [x] update scripts
- [x] update doc
- mk dia in [PlantUML](http://www.plantuml.com/plantuml/uml/)
- vacuumdb [-h ...] -U btcuser -Fqz btcdb
- CREATE _UNLOGGED_ txo ... (250k: t-15%)
- _test_400.sh (&le; 2016-02-25)
- test xload indexed
- xload into separate script
- Partial xload:
  - all/1y/6m/3m
  - all/till/from/in

## Partial TXO

\# | Lim      | Cond
---|----------|------
1  | D&sup1;] | d0&le;D&sup1;
2  | [D&deg;  | d1&ge;D&deg;&or;&empty;
3  | [D&deg;&hellip;D&sup1;] | &not;(d0&gt;D1 &or; d1&lt;D0)

Bit table:

d0\1 | <D0 |D0-D1| >D1 |&empty;
-----|:---:|:---:|:---:|:---:
\<D0 |  -  |  +  |  +  |  +
D0-D1|  ×  |  +  |  +  |  +
\>D1 |  ×  |  ×  |  -  |  -

- &not;(d0&gt;D1 &or; d1&lt;D0)
- d0&le;D1 & (d1&ge;D0 &or; &empty;)

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
