# TODO

## - Next:

- merge import+convert=impex
- query.stat
  - tables (simple list)
  - indexed/indices
  - rec counts
  - db size:
    - p: ```SELECT pg_size_pretty( pg_database_size('dbname') );```
    - m: ```SELECT SUM(data_length + index_length) AS size FROM information_schema.tables WHERE table_schema = (SELECT DATABASE());```
- FIXME: bce2 - timestamp must be w/o \'

## Future:

- tiny: uniq a_id+date0+date1
- import midi/tiny
- merge impex+dbctl=...
- bcerq.py &rArr; bcerq.sh (bash (env, eval), envsubst, m4, sed, perl)

## - Done:
- 201207 bcedb.tiny: mysql/pgsql
- 201209 bcedb.midi: mysql/pgsql
- 201209 bcedb.full: mysql/pgsql
- 201209 import.full.pgsql
- 201209 bcerq.cmd.*
- 201209 import.full: mysql/pgsql
- 201210 FIXME: mysql DROP PKEY
- 201210 impex.sh from multiple .txt.gz
- 201218: import/convert merge/split into 3 parts

## - Misc

- DB connector: try
  - [mysql-connector-python](https://pypi.org/project/mysql-connector-python/)-8.0.22
  - [-mariadb](https://mariadb.com/docs/appdev/connector-python/)-1.0.5
  - [-PyMySQL](https://pypi.org/project/PyMySQL/) (lin/mac)
  - python3-mysqlclient (?)
- DB: full/midi/tiny x psql/mysql:
  - full: asis
  - midi:
     - bk: date:DATE
     - tx: ~~hash~~ (or no index hash)
     - data: ~~!addr~~, ~~money=0~~
     - addr: ~~multisig~~, name:!idx
  - tiny: addr+data
- [ ] Documenting:
  - [ ] prepare DB: pgsql/sqlite/mysql
  - import
  - convert
  - bcerq
  - queries
- bcepy/utils/ &rarr; import/
- import: add right into short db
- host003: pgsql/mysql
- bitcoind: find script parser
- future:
  - httpd
  - optimize bce2
  - update db (&rArr; 2 &times; DB)

## Headers

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
