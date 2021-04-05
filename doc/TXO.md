# TXO

`TXO` is main source for [queries](BCERQ.md).
This can be as SQL table as SQL view, but only one from this at the same time.
You must create one before making a query.

*Warning: be sure that you **indexed** all 4 previous tables before next steps.*

## 1. Table

*Warning: be sure that you a) **created** `txo` table, b) it is **empty** and c) **not** indexed before next steps.*

### 1.1. Create

1. Create table if it is not:

   `./bcedb.sh create x`

1. Load data:

   `./bcedb.sh xload x`

1. Create its indexes and constraints:

   `./bcedb.sh idx x`

### 1.2. Delete

1. Drop indexes and constraints:

   `./bcedb.sh unidx x`

1. Clean data table:

   `./bcedb.sh trunc x`

1. Or drop table at all:

   `./bcedb.sh drop x`

## 2. View

### 2.1. Create

`psql -f sql/dbctl/x/z.sql $BTCDB $BTCUSER`

### 2.2. Delete

`psql -c 'DROP VIEW txo;' $BTCDB $BTCUSER`

## 3. Switch Table &lrarr; View

To switch between Table and View you must destroy 1st and create 2nd:

- Table &rArr; View:
	1. Delete Table (1.2)

		*Note: another way - rename table: `ALTER TABLE txo RENAME TO _txo;`*

	1. Create View (2.1)

- View &rArr; Table:
	1. Drop *(or rename)* View (2.2)
	1. Create table (1.1)
