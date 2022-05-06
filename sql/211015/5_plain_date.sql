-- 5_0_0: Prepare const; Timing: 0"
DROP TABLE IF EXISTS tmp_today;
CREATE TEMP TABLE tmp_today AS
SELECT DISTINCT
    DATE(datime) AS d,
    MIN(tx.id) AS tx0,
    MAX(tx.id) AS tx1
FROM tx
INNER JOIN bk ON tx.b_id = bk.id
WHERE DATE(datime) = '2022-03-31'
GROUP BY d;
-- 5_0_1: Fill daily snapshot
-- Note: change 'tail' to 'vout'
-- Timing (2022-03-31): 20' (vout) / 4'20" (tail); 80969927 records
-- Count: 132038344 (all) = 80969927 + 296027/10648.46354633 BTC (aid is null & money > 0) + 50772390 (money = 0)
DROP TABLE IF EXISTS tmp_daysnap;
WITH const (tx0, tx1) AS (SELECT DISTINCT tx0, tx1 FROM tmp_today)
SELECT tail.*
    INTO TEMP TABLE tmp_daysnap
    FROM const, tail
    WHERE
        t_id <= const.tx1
        AND (t_id_in > const.tx0 OR t_id_in IS NULL)
        AND a_id IS NOT NULL
        AND money > 0
;
CREATE INDEX tmp_daysnap_t_id_idx ON tmp_daysnap (t_id);
CREATE INDEX tmp_daysnap_t_id_in_idx ON tmp_daysnap (t_id_in);
CREATE INDEX tmp_daysnap_a_id_idx ON tmp_daysnap (a_id);
CREATE INDEX tmp_daysnap_money_idx ON tmp_daysnap (money);
ALTER TABLE tmp_daysnap ADD CONSTRAINT tmp_daysnap_pkey PRIMARY KEY (t_id,n);
-- 5_0_2: Fill addr buratinity
-- Timing (2022-03-31): … (vout) / 3'30" (tail) / 3'0" (tmp_daysnap); 41324455 records
DROP TABLE IF EXISTS tmp_rid;
WITH const (tx1) AS (SELECT DISTINCT tx1 FROM tmp_today)
SELECT
    a_id,
    CASE
      WHEN SUM(money) BETWEEN 1 AND 10^5 THEN 1
      WHEN SUM(money) BETWEEN 1+10^5 AND 10^6 THEN 2
      WHEN SUM(money) BETWEEN 1+10^6 AND 10^7 THEN 3
      WHEN SUM(money) BETWEEN 1+10^7 AND 10^8 THEN 4
      WHEN SUM(money) BETWEEN 1+10^8 AND 10^9 THEN 5
      WHEN SUM(money) BETWEEN 1+10^9 AND 10^10 THEN 6
      WHEN SUM(money) BETWEEN 1+10^10 AND 10^11 THEN 7
      WHEN SUM(money) BETWEEN 1+10^11 AND 10^12 THEN 8
      WHEN SUM(money) BETWEEN 1+10^12 AND 10^13 THEN 9
      WHEN SUM(money) BETWEEN 1+10^13 AND 10^14 THEN 10
      WHEN SUM(money) > 10^14 THEN 11
    END AS rid
INTO
    TEMP TABLE tmp_rid
FROM
    tmp_daysnap, const
WHERE
    t_id <= const.tx1
    AND (t_id_in > const.tx1 OR t_id_in IS NULL)
    AND a_id IS NOT NULL
    AND money > 0
GROUP BY
    a_id;
CREATE INDEX IF NOT EXISTS tmp_rid_rid_idx ON tmp_rid (rid);
ALTER TABLE tmp_rid ADD CONSTRAINT tmp_rid_pkey PRIMARY KEY (a_id);
-- R.1: Addr_Num (addrs number to the end of tx); Timing: 12"
DELETE FROM t_1a_date WHERE t_1a_date.d IN (SELECT DISTINCT d FROM tmp_today) AND qid = 1;
WITH const (d) AS (SELECT DISTINCT d FROM tmp_today)
INSERT INTO t_1a_date (d, qid, rid, val)
SELECT
    const.d,
    1,
    tmp_rid.rid,
    COUNT(*) AS val
FROM const, tmp_rid
GROUP BY const.d, rid;
-- R.2: Addr_Num_Active (addrs number active B2n txs); Timing: 50"
DELETE FROM t_1a_date WHERE t_1a_date.d IN (SELECT DISTINCT d FROM tmp_today) AND qid = 2;
WITH const (d) AS (SELECT DISTINCT d FROM tmp_today)
INSERT INTO t_1a_date (d, qid, rid, val)
SELECT
    const.d,
    2,
    tmp_rid.rid,
    COUNT(*) AS val
FROM const, tmp_rid
INNER JOIN (
    WITH const (tx0, tx1) AS (SELECT DISTINCT tx0, tx1 FROM tmp_today)
    SELECT
        DISTINCT a_id
    FROM
        const, tmp_daysnap
    WHERE
        (t_id BETWEEN const.tx0 AND const.tx1)
        OR (t_id_in BETWEEN const.tx0 AND const.tx1)
    ) AS active ON tmp_rid.a_id = active.a_id
GROUP BY const.d, tmp_rid.rid;
-- R.3: Utxo_Num (UTXO numbers to the end of the tx); Timing:
DELETE FROM t_1a_date WHERE t_1a_date.d IN (SELECT DISTINCT d FROM tmp_today) AND qid = 3;
WITH const (d, tx1) AS (SELECT DISTINCT d, tx1 FROM tmp_today)
INSERT INTO t_1a_date (d, qid, rid, val)
SELECT
    const.d,
    3,
    tmp_rid.rid,
    COUNT(*) AS num
FROM const, tmp_rid
INNER JOIN tmp_daysnap ON tmp_rid.a_id = tmp_daysnap.a_id
WHERE
    t_id <= const.tx1 AND
    (t_id_in > const.tx1 OR t_id_in IS NULL)
GROUP BY const.d, tmp_rid.rid;
-- R.4: Utxo_Sum (addrs summs to the end of the tx); Timing: 1'30"
DELETE FROM t_1a_date WHERE t_1a_date.d IN (SELECT DISTINCT d FROM tmp_today) AND qid = 4;
WITH const (d, tx1) AS (SELECT DISTINCT d, tx1 FROM tmp_today)
INSERT INTO t_1a_date (d, qid, rid, val)
SELECT
    const.d,
    4,
    tmp_rid.rid,
    SUM(money) AS num
FROM const, tmp_rid
INNER JOIN tmp_daysnap ON tmp_rid.a_id = tmp_daysnap.a_id
WHERE
    t_id <= const.tx1 AND
    (t_id_in > const.tx1 OR t_id_in IS NULL)
GROUP BY const.d, tmp_rid.rid;
-- R.5: Vout_Num (vouts number B2n txs); Timing: 20"
DELETE FROM t_1a_date WHERE t_1a_date.d IN (SELECT DISTINCT d FROM tmp_today) AND qid = 5;
WITH const (d, tx0, tx1) AS (SELECT DISTINCT d, tx0, tx1 FROM tmp_today)
INSERT INTO t_1a_date (d, qid, rid, val)
SELECT
    const.d,
    5,
    tmp_rid.rid,
    COUNT(*) AS val
FROM const, tmp_rid
INNER JOIN tmp_daysnap ON tmp_rid.a_id = tmp_daysnap.a_id
WHERE
    t_id BETWEEN const.tx0 AND const.tx1
    AND (t_id_in > const.tx1 OR t_id_in IS NULL)
GROUP BY const.d, tmp_rid.rid;
--- R.6: Vout_Sum (vouts sums B2n txs); Timing: 20"
DELETE FROM t_1a_date WHERE t_1a_date.d IN (SELECT DISTINCT d FROM tmp_today) AND qid = 6;
WITH const (d, tx0, tx1) AS (SELECT DISTINCT d, tx0, tx1 FROM tmp_today)
INSERT INTO t_1a_date (d, qid, rid, val)
SELECT
    const.d,
    6,
    tmp_rid.rid,
    SUM(money) AS val
FROM const, tmp_rid
INNER JOIN tmp_daysnap ON tmp_rid.a_id = tmp_daysnap.a_id
WHERE
    t_id BETWEEN const.tx0 AND const.tx1
    AND (t_id_in > const.tx1 OR t_id_in IS NULL)
GROUP BY const.d, tmp_rid.rid;
DROP TABLE IF EXISTS tmp_rid;
DROP TABLE IF EXISTS tmp_daysnap;
DROP TABLE IF EXISTS tmp_today;
