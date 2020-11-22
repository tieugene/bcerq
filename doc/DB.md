# DB
Maintaining database.

## Full

Old schema:

| Table | Field | Type | Len | Constraint |
|-------|-------|------|-----|------------|
|asdfghj||
|DSFGsdfg|||
|qegfsdgasd||||
| mytable ||||||
| myfield |

New schema:

## Short

| Table | Field  | Type  | !Null | Contraint |
|-------|--------|-------|-----|-----------|
| Addr | id      | Int32 |  +  | Uniq |
|      | name    | str   |  +  | Uniq |
| Data | a_id    | IDREF |  +  | addr.id |
|      | date0   | DATE  |  +  | |
|      | date1   | DATE  |  -  | |
|      | satoshi | Int64 |  +  | > 0  |
| _PK_ | a_id+date0+date1|  +  | Uniq |

## Misc
- reindex PKs etc:

	```
	for t in blocks transactions addresses data; do psql -q -c "REINDEX TABLE $t;" $BTCDB $BTCUSER; done
	```

- updates:

	```
	(echo "BEGIN;"; unpigz -c 0xx.vin.gz; echo "COMMIT;") | psql -q $BTCDB $BTCUSER
