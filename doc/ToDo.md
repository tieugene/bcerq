# ToDo

## Hot:

- mk *.sh/py path independent
- query.stat
  - tables (simple list)
  - indexed/indices
  - rec counts
  - db size: `SELECT pg_size_pretty(pg_database_size('dbname'));`
- FIXME: bce2 - timestamp must be w/o \'

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

## Headers:

вот так колонки обозвать
-- "name": "addr_gt"
-- "header": ["a_id", "address", "profit, ㋛"]
-- "header": ["a_id", "address", "balance>N, data"]

-- "name": "addr_btc_max",
-- "header": ["a_id", "address", "∑₀, ㋛", "∑₁, ㋛", "gain, ㋛"],
-- "header": ["a_id", "address", "begin data", "end data", "abs gain "],

-- "name": "addr_btc_min",
-- "header": ["a_id", "address", "begin data", "end data", "abs loss"],

-- "name": "addr_cnt_max",
-- "header": ["a_id", "address", "begin data", "end data", "rel gain, %"],

-- "name": "addr_cnt_min",
-- "header": ["a_id", "address", "begin data", "end data", "rel loss, %"],

-- "name": "alist_btc_gt",
-- "header": ["a_id", "address", "begin data, ₿", "end data, ₿", "abs gain >N, ₿"],

-- "name": "alist_btc_lt",
-- "header": ["a_id", "address", "begin data, ₿", "end data, ₿", "abs loss >N, ₿"],

-- "name": "alist_cnt_gt",
-- "header": ["a_id", "address", "begin data, ₿", "end data, ₿", "abs gain>N, ₿", "rel gain>N, %"],

-- "name": "alist_cnt_lt",
-- "header": ["a_id", "address", "begin data, ₿", "end data, ₿", "abs loss>N, ₿", "rel loss>N, %"],

-- "name": "alist_moves",
-- "header": ["a_id", "address", "begin data, ₿", "end data, ₿", "abs change, ₿", "rel change, %"],
