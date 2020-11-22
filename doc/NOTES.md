# BCERQ - BitCoin Export ReQuests
Tool to process bce2 exported SQL DB.

## Tasks
1. Top X addresses with max **abs** <sub>&Delta;</sub>&sum; (&#x20BF;) on <sub>&Delta;</sub>D.
2. Top Y addresses with max **rel** <sub>&Delta;</sub>&sum; (%) on <sub>&Delta;</sub>D (((&sum;<sub>1</sub>÷&sum;<sub>0</sub>)-1)×100%))
3. **Abs** (&#x20BF;) and **rel** (%) <sub>&Delta;</sub>&sum; of addresses from **list** on <sub>&Delta;</sub>D.
4. Addresses with &sum; &gt; &#x20BF;X on D[ate].
5. <sub>&Delta;</sub>&sum; of addresses from **list** on <sub>&Delta;</sub>D.
6. <sub>&Delta;</sub>&sum; of addresses from **list** > or < X% on <sub>&Delta;</sub>D.
7. Addresses crossing between <sub>&Delta;</sub>Ds.

Legend:

- **&sum;** - balance = inputs till date - outputs on date
  - <sub>&Delta;</sub>&sum; - &sum; changing (&sum;<sub>1</sub> - &sum;<sub>0</sub>), e.g.
  - &sum;&uarr; - &sum; increasing (<sub>&Delta;</sub>&sum; > 0)
  - &sum;&darr; - &sum; decreasing (<sub>&Delta;</sub>&sum; < 0)
- **<sub>&Delta;</sub>D** - period = date slice date<sub>0</sub>&hellip;date<sub>1</sub>
- **List** - defined addresses list
- **Abs** - absolute (&#x20BF;)
- **Rel** - relative (%)

## Prereq

Utility subqueries

### View

- view_txo_all.sql (all records)
- view_txo_real.sql (single address)

### &sum; on date

Balance on (before) date $DATE = all in (vout) but not out (vin) *before* date:

```sql
SELECT addr, sum(satoshi) AS itogo
FROM txo_real
WHERE (date0 < '$DATE') AND (date1 >= '$DATE' OR date1 IS NULL)
GROUP BY addr
```

### Limits

Limit | 1&uarr; | 1&darr; | 2&uarr; | 3&uarr; |
------|-----|-----|-----|-----|-----
- <s>&sum;<sub>0</sub></s>&hellip;<s>&sum;<sub>1</sub></s> | &cross; | &cross; | &cross; 
- <s>&sum;<sub>0</sub></s>&hellip;&sum;<sub>1</sub> | &check; | &cross; | &cross;
- &sum;<sub>0</sub>&hellip;<s>&sum;<sub>1</sub></s> | &cross; | &check; | &cross;
- &sum;<sub>0</sub>&hellip;&sum;<sub>1</sub> | &check; | &check; | &check;

## Solutions

### 1. Top &#9993;[] by <sub>&Delta;</sub>&sum;&#x20BF; in <sub>&Delta;</sub>D.

- file: [addr_abs_btc_max.sql](sql/addr_abs_btc_max.sql), [addr_abs_btc_min.sql](sql/addr_abs_btc_min.sql)
- In: DATE0, DATE1, TOPX (date: YYYY-MM-DD)
- Out: addr, &sum;
- Action: &sum;<sub>1</sub> - &sum;<sub>0</sub>
- Limits: &sum;<sub>0</sub>?&hellip;&sum;<sub>1</sub>+
- Timing: 4'

&darr;: &cross; fresh, &check; finished => b LEFT JOIN e

### 2. Top &#9993;[] by <sub>&Delta;</sub>&sum;% in <sub>&Delta;</sub>D.

- Timing: 3'30" (374,194,272 s)
- file: addr_rel_btc_max.sql

### 4. Addrs w/ &sum; > &#x20BF;_N_ on date

- Timing: 3'10"
- File: [addr_over_btc.sql](sql/addr_over_btc.sql)

### 5. <sub>&Delta;</sub>&sum;(&#x20BF;?) in <sub>&Delta;</sub>D for &#9993;[&hellip;].

- File: alist_abs_btc_chg.sql

Test on:

id | address | begin | end | txs
---|---|---|---|---
6085702 | 1P1UHmzTyQbENLYUA75KFEQp9gq6CBpcyX | 2012-08-31 | 2012-09-01 | 2
2817725 | 1DkyBEKt5S2GDtv7aQw6rQepAvnsRyHoYM | 2012-01-09 | 2020-09-01 | 765
3746156 | 1317PDZC7cKDabz4y7dLkNxS1WWZcDcXXY | 2012-05-14 | 2016-06-21 | 227

Tests (1):

- 0-0 2010-01-01 2010-12-31 &check;
- 0-1 2012-01-01 2012-05-31 &check;
- 1-0 2012-06-01 2012-12-31
- 1-1 

### 3. <sub>&Delta;</sub>&sum;(&#x20BF;,%) in <sub>&Delta;</sub>D for &#9993;[&hellip;].

- In: DATE0, DATE1, ADDR\[&hellip;] (csv)
- Out: addr, &Delta;&sum;&#x20BF;, &Delta;&sum;%
- Action:
- Limits: &sum;<sub>0</sub>?&hellip;&sum;<sub>1</sub>+
- Timing:
- File: [alist_abs_btc_chg_gt.sql](sql/alist_abs_btc_chg_gt.sql)

### 6. <sub>&Delta;</sub>&sum;(&#x20BF;,%) in <sub>&Delta;</sub>D for &#9993;[&hellip;] where <sub>&Delta;</sub>&sum; &gl;_N_%.

(To be continued)

### 7. &#9993;[&hellip;] \(&cap; &#9993;[&hellip;])+

- In: 2+ *.csv with columns (a_id, addr, &hellip;) (Note: skip header)
- Out: &cap; of lists

Action:

- load id: addrs (all)
- mk set()s
- set() & set() & &hellip;
- print set(): addr

## JSONB

IDEAS:

- CREATE FUNCTION
- SELECT data GROUP BY end_month[+1] EXCLUDE(mon0=mon1)
- SELECT all date0 in this mon - all date1 in this month + нарастающий итог
- CROSS JOIN
- [RTFM](https://postgrespro.ru/docs/postgresql/12/queries-with)

Get types of json ('string', 'array'):

```sql
SELECT jsonb_typeof(a_list) AS typ, count(*) from addresses GROUP BY typ ORDER BY typ DESC;
```

Get all 01.mm.yyyy:
(200k = 2009-01-03..2012-09-22)

```sql
SELECT DISTINCT DATE(DATE_TRUNC('month', b_time)) AS firsts FROM blocks ORDER BY firsts ASC;
```


All UTXO on 01.mm.yyyy: utxo_all.sql

Multisig UTXO on 01.mm.yyyy:

```
...
WHERE
...
  AND jsonb_typeof(addr) = 'array'
...
```
