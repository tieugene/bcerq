# DB

Maintaining database.

Used DB backends - PostgreSQL or MariaDB/MySQL.

## 1. Usage

`bcedb.py` script uses options as from config as from command line as from backend-specific configs: cfg (~/.bcerq.ini) &rArr; CLI &rArr; _backend.cfg_ (.my.cnf/.pgpass).
CLI overwrites bcerq.ini, backend configs _appends_ settings.

## 2. Scheme

Legend:

- ∅ - NOT NULL
- U - Uniq (indexed, null)
- P - Primary key (Uniq, !null)

### Full

Whole usual blockchain info.

| Name     | Type      | Idx | ∅   | Note |
|----------|-----------|-----|-----|------|
| **_addr_** |
| id       | INT       | _P_ | +   |
| name     | JSON[B]   |~~U~~| +   |
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

### Midi

All data required for datum queries and updating them further.

TODO: what to do with multisig and vout.addr is null?

| Name     | Type      | Idx | ∅   | Note |
|----------|-----------|-----|-----|------|
| **_addr_** |
| id       | INT       | _P_ | +   |
| name     | VCHAR(64)⚠|~~U~~| +   |
| **_bk_** |
| id       | INT       | _P_ | +   |
| datime   | DATE⚠     | +⚠  | +   |
| **_tx_** |
| id       | INT       | _P_ | +   |
| b_id     | INT       | +   | +   | bk.id |
| **_vout_** |
| t_id     | INT       | _p_ | +   | tx.id |
| n        | INT       | _p_ | +   |
| t\_id_in | INT       | +   | -   | tx.id |
| a_id     | INT       | +   | ?⚠  | addr.id |
| money    | BIGINT    | +   | +   |

### Tiny

Smallest tables for fastest queries.
Cannot updatable with future data.

| Name   | Type       | Idx | ∅ | Note |
|--------|------------|-----|---|------|
| **_addr_** |
| id      | INT       | _P_ | + |
| name    | VCHAR(64) |~~U~~| + |
| **_vout_** |
| a_id    | INT       |  +  | + | p.1 |
| date0   | DATE      |  +  | + | p.2 |
| date1   | DATE      |  +  | - | p.3 |
| money | BIGINT    |  +  | + | > 0 |

## 2. Actions

Ordinar [workflow](WorkFlow.dot):

- Create DB &rArr; Create tables &rArr; Import data &rArr; Indexing &rArr; (queries) &rArr; Unindexing &rArr; Trunc &rArr; Drop tables &rArr; Drop DB.

_Note: Import itself is not job of this tool (see [ImEx](ImpEx.md))._

1. create tables (if not exist)
1. ~~import data~~
1. create indices
1. &hellip;
1. drop indices (if exist)
1. drop data
1. drop tables (if exist)
1. clean up

Note: create/drop/unindex - if not exists; index/

## 3. SQL

Most of actions are carried out with SQL scripts in separate files.
Paths to sql scripts depend on scheme, table, SQL-dialect and action itself:

_&lt;scheme&gt;_/_&lt;table&gt;_/[_&lt;backend&gt;_/]_&lt;action&gt;_.sql

- Scheme:
  - f[ull]
  - m[idi]
  - t[iny]
- Backend:
  - m[ariadb]
  - p[ostgresql]
- Table:
  - a[ddress]
  - b[lock]
  - t[ransaction]
  - v[out]
- Command (use `list` to help):
  - create
  - indexing
  - unindexing
  - show (tables)
  - wash (vacuum/optimize)
  - trunc (drop data)
  - drop (tables)

Note: action runs in order: _&lt;table&gt;_/_&lt;action&gt;_.sql (if exists) &rArr; _&lt;table&gt;_/_&lt;backend&gt;_/_&lt;action&gt;_.sql (if exists)
