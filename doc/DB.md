# DB
Maintaining database.

Used DB backends - PostgreSQL or MariaDB/MySQL.

## 1. Usage

`bce_db.py` script uses options as from config as from command line as from backend-specific configs: cfg (~/.bcerq.ini) &rArr; CLI &rArr; _backend.cfg_ (.my.cnf/.pgpass)

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
| name     | JSON[B]   | U?  | +   |
| qty      | INT       | +   | +   |
| **_bk_** |
| id       | INT       | _P_ | +   |
| datime   | TIMESTAMP | U   | +   |
| **_tx_** |
| id       | INT       | _P_ | +   |
| hash     | CHAR(64)  | U?  | +   |
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
| name     | VCHAR(64)⚠| U   | +   |
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
| satoshi | BIGINT    |  +  | + | > 0 |

## 2. Actions

Ordinar workflow:
Create tables &rArr; Import data &rArr; Indexing &rArr; Clean up.
Import itself is not job of this tool (see [Import](Import.md)).

1. create table (if not exists)
1. ~~import data~~
1. create indices
1. drop indices (if exist)
1. drop data
1. drop tables (if exists)
1. clean up

Note: create/drop/unindex - if not exists; index/

## 3. SQL

Most of actions are carried out with SQL scripts in separate files.
Some actions (drop data, drop tables) are SQL-dialect-independent and hardcoded into main script.
Paths to sql scripts depend on scheme, table, SQL-dialect and action itself:

_&lt;scheme&gt;_/_&lt;table&gt;_/[_&lt;backend&gt;_/]_&lt;action&gt;_.sql

- Scheme:
  - f[ull]
  - m[idi]
  - t[iny]
- Table:
  - a[ddress]
  - b[lock]
  - t[ransaction]
  - v[out]
- Backend:
  - m[ariadb]
  - p[ostgresql]
- Action:
  - c[reate]
  - i[indexin]
  - u[nindexing]

Note: action runs in order: _&lt;table&gt;_/_&lt;action&gt;_.sql (if exists) &rArr; _&lt;table&gt;_/_&lt;backend&gt;_/_&lt;action&gt;_.sql (if exists)

## TODO

- move to external SQLs:
  - Import:
    - p: COPY table FROM STDIN
    - m: LOAD ... / maradb-import
