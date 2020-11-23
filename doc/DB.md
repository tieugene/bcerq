# DB
Maintaining database.

## Schema

Legend:

- !Nl - NOT NULL
- U - Uniq (indexed?, not null?)
- P - Primary key (Uniq, not null?)

Full:

| Name   | Type      | Idx | !Nl | Note | TODO |
|--------|-----------|-----|-----|------|------|
| **_blocks_** ||||| **_bk_** |
| b_id   | INT32     | _P_ | +   | | id |
| b_time | TIMESTAMP | +   | +   | | ?:U |
| **_transactions_** ||||| **_tx_** |
| t_id   | INT       | _P_ | +   | | id |
| b_id   | INT       | +   | +   | a.id | |
| hash   | STR[64]   | U   | +   | | |
| **_addresses_** ||||| **_addr_** |
| a_id   | BIGINT    | _P_ | +   | | id:int |
| a_list | JSONB     | U   | +   | | name |
| n      | INT       | -   | +   | | del |
| **_data_** |
| t\_out_id | INT    | _p_ | +   | | t_id |
| t\_out_n | INT     | _p_ | +   | | n |
| t\_in_id | INT     | +   | -   | | t\_id_in |
| a_id   | BIGINT    | +   | -   | | |
| satoshi | BIGINT   | +   | +   | | money |

Short:

| Name   | Type  | Idx | !Nl | Note |
|--------|-------|-----|-----|------|
| **_addr_** |
| id      | Int32 | _P_ | +   | |
| name    | str   | U   | +   | |
| **_data_** |
| a_id    | IDREF |  +  | + | P/U.1 |
| date0   | DATE  |  +  | + | P/U.2 |
| date1   | DATE  |  +  | - | P/U.3 |
| satoshi | Int64 |  +  | + | > 0 |

## Actions

1. create tables
1. create data

	```
	(echo "BEGIN;"; unpigz -c 0xx.vin.gz; echo "COMMIT;") | psql -q $BTCDB $BTCUSER
	```
1. create indices
1. drop indices
1. drop data
1. drop tables
1. vacuum
