# Convert

Convert source DB into other.

DB engines:

- MySQL
- PostgreSQL

Convertions:

- full &rArr; midi
- full &rArr; tiny
- midi &rArr; tiny

Test:

- Limits:
  - blocks: 200k
  - dates: [2012-01-01&hellip;]2012-08-31
  - num: 50/1M (top/over)
- Queries - top addrs by:
  - max profit in period (&#x20BF;)
  - max loss in perios (&#x20BF;)
  - max profit in period (%)
  - max loss in period (%)
  - &sum; > x&#x20BF;

## 1. PostgreSQL

Idea: export | file.gz | COPY import

Try: export | import

Usuals:

- ? disable journal on import

### Timing

- exp: 86"
- imp: 97"
- idx: 42"

## 2. Sqlite

TODO: import from csv:

```
.mode csv [tablename]
.separator "\t"
.import <filename> <tablename>
```

Idea: export | bulk INSERT

Usuals:

- -bulk
- -readonly

- Create: [Addr](1_c_a.sql), [Data](1_c_d.sql)
- Export: [Addr](2_e_a.sql), [Data](2_e_d.sql)
- Import: 
- Indices: [Addr](3_i_a.sql), [Data](3_i_d.sql)

### Timing

- export psql > sql.gz: 130" = 21" (addr, 185M) + 109" (data, 76M)
- import sql.gz: 54" = 19" (256M) + 35" (=494M)
- index: ~22" (1221M)
- alltogether: 195" (30 (a) + 134 (d) + 30 (i))

## 3. MySQL

## Check (100k):

Part\Dst|Full|Midi|Tiny|
--------|----|----|----|
txt2tsv | +  | .  | .  |
tsv2db  | mp | mp | mp |
F.db2tsv| mp | mp | mp |
M.db2tsv| -- | mp | mp |
T.db2tsv| -- | -- | mp |
utxo    | mp | mp | mp |

## Results

psql/mysql &times; full/midi/tiny &times; utxo/...

UTXO | Full | Midi | Tiny
-----|------|------|-----
MySQL|  |  |
PgSQL|  |  |

Query | rq | l@h | psql
------|----|-----|------
btc_max | 90-120" | 14 | 13
btc_min | 90-120" | 16 | 13
btc_over | 60"+ | 6 | 7
cent_max | 90-120" | 15 | 13
cent_min | 90-120" | 15 | 13
