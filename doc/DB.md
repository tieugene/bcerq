# DB

Maintaining database.
&hellip;

## 1. Usage

`bcedb.sh` script uses options as from config as from command line as from backend-specific configs: \~/.bcerq.ini &rArr; CLI &rArr; \~/.pgpass.
CLI overwrites .bcerq.ini, .pgpass _appends_ settings.

## 2. Scheme

Legend:

- ∅ - NOT NULL
- U - Uniq (indexed, null)
- P - Primary key (Uniq, !null)

| Name     | Type      | Idx | ∅   | Note |
|----------|-----------|-----|-----|------|
| **_addr_** |
| id       | INT       | _P_ | +   |
| name     | JSONB     |~~U~~| +   |
| qty      | INT       | +   | +   |
| **_bk_** |
| id       | INT       | _P_ | +   |
| datime   | TIMESTAMP | U   | +   |
| **_tx_** |
| id       | INT       | _P_ | +   |
| hash     | CHAR(64)  |~~U~~| +   |
| b_id     | INT       | +   | +   | bk.id |
| **_vout_** |
| t_id     | INT       | _p_ | +   | tx.id |
| n        | INT       | _p_ | +   |
| t\_id_in | INT       | +   | -   | tx.id |
| a_id     | INT       | +   | -   | addr.id |
| money    | BIGINT    | +   | +   |
| **_txo_** |
| a_id    | INT       |  +  | + | p.1 |
| date0   | DATE      |  +  | + | p.2 |
| date1   | DATE      |  +  | - | p.3 |
| money   | BIGINT    |  +  | + | > 0 |

## 3. Actions

Ordinar [workflow](WorkFlow.dot):

- Create DB &rArr; Create tables &rArr; Import data &rArr; Indexing &rArr; [Re]load `txo` &rArr; (queries) &rArr; Unindexing &rArr; Trunc &rArr; Drop tables &rArr; Drop DB.

_Note: Import itself is not job of this tool (see [ImpEx](ImpEx.md))._

1. create tables (if not exist)
1. ~~import data~~
1. create indexes
1. &hellip;
1. drop indexes (if exist)
1. drop data
1. drop tables (if exist)
1. clean up

## 4. SQL

Most of actions are carried out with SQL scripts in separate files.
Paths to sql scripts depend on table and action itself:

_sql/dbctl_/_&lt;table&gt;_/_&lt;action&gt;_.sql

- Table:
  - a[ddress]
  - b[lock]
  - t[ransaction]
  - v[out]
- Command:
  - create
  - indexing
  - unindexing
  - show (tables)
  - wash (vacuum)
  - trunc (delete data)
  - drop (delete tables)
