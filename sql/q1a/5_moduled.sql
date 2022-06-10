CREATE OR REPLACE PROCEDURE __tbl_c_tmp_snap()
    LANGUAGE sql
AS
$$
CREATE TEMP TABLE IF NOT EXISTS tmp_snap (LIKE vout INCLUDING ALL);
$$;
COMMENT ON PROCEDURE __tbl_c_tmp_snap() IS 'Temporary vout snapshot.
@ver: 22020507.12.00';

CREATE OR REPLACE PROCEDURE __tbl_c_tmp_rid()
    LANGUAGE sql
AS
$$
CREATE TEMP TABLE IF NOT EXISTS tmp_rid (a_id INTEGER NOT NULL PRIMARY KEY, rid SMALLINT NOT NULL);
$$;
COMMENT ON PROCEDURE __tbl_c_tmp_rid() IS 'Temporary buratinity table.
@ver: 22020507.12.05';

CREATE OR REPLACE FUNCTION __dom_min(d DATE)
    -- 1st day of month
    RETURNS DATE
    LANGUAGE sql
AS
$$
SELECT DATE_TRUNC('month', d)::DATE;
$$;

CREATE OR REPLACE FUNCTION __dom_max(d DATE)
    -- Last day of month
    RETURNS DATE
    LANGUAGE sql
AS
$$
SELECT DATE_TRUNC('month', d)::DATE + INTERVAL '1 month -1 day';
$$;

CREATE OR REPLACE PROCEDURE __snap_idx()
    LANGUAGE sql
AS
$$
    CREATE INDEX tmp_snap_t_id_idx ON tmp_snap (t_id);
    CREATE INDEX tmp_snap_t_id_in_idx ON tmp_snap (t_id_in);
    CREATE INDEX tmp_snap_a_id_idx ON tmp_snap (a_id);
    CREATE INDEX tmp_snap_money_idx ON tmp_snap (money);
    ALTER TABLE tmp_snap
        ADD CONSTRAINT tmp_snap_pkey PRIMARY KEY (t_id, n);
    $$;

CREATE OR REPLACE PROCEDURE __snap_unidx()
    LANGUAGE sql
AS
$$
    ALTER TABLE tmp_snap
        DROP CONSTRAINT IF EXISTS tmp_snap_pkey;
    DROP INDEX IF EXISTS tmp_snap_t_id_idx;
    DROP INDEX IF EXISTS tmp_snap_t_id_in_idx;
    DROP INDEX IF EXISTS tmp_snap_a_id_idx;
    DROP INDEX IF EXISTS tmp_snap_money_idx;
    $$;

CREATE OR REPLACE PROCEDURE _snap_fill(tx0 INTEGER, tx1 INTEGER)
    LANGUAGE sql
AS
$$
    -- 5_0_1: Fill day/month snapshot
    -- FIXME: tail
TRUNCATE TABLE tmp_snap;
CALL __snap_unidx();
INSERT INTO tmp_snap (t_id, n, t_id_in, money, a_id)
SELECT t_id, n, t_id_in, money, a_id
FROM vout
WHERE t_id <= tx1
  AND (t_id_in > tx0 OR t_id_in IS NULL)
  AND a_id IS NOT NULL
  AND money > 0;
CALL __snap_idx();
$$;

CREATE OR REPLACE PROCEDURE __rid_idx()
    LANGUAGE sql
AS
$$
    ALTER TABLE tmp_rid
        ADD CONSTRAINT tmp_rid_pkey PRIMARY KEY (a_id);
    CREATE INDEX IF NOT EXISTS tmp_rid_rid_idx ON tmp_rid (rid);
    $$;

CREATE OR REPLACE PROCEDURE __rid_unidx()
    LANGUAGE sql
AS
$$
    ALTER TABLE tmp_rid
        DROP CONSTRAINT IF EXISTS tmp_rid_pkey;
    DROP INDEX IF EXISTS tmp_rid_rid_idx;
    $$;

CREATE OR REPLACE PROCEDURE _rid_fill(tx1 INTEGER)
    LANGUAGE sql
AS
$$
    -- 5_0_2: Fill addr buratinity
    -- Timing (2022-03-31): … (vout) / 3'30" (tail) / 3'0" (tmp_daysnap); 41324455 records
TRUNCATE TABLE tmp_rid;
CALL __rid_unidx();
INSERT INTO tmp_rid (a_id, rid)
SELECT a_id,
       CASE
           WHEN SUM(money) BETWEEN 1 AND 10 ^ 5 THEN 1
           WHEN SUM(money) BETWEEN 1 + 10 ^ 5 AND 10 ^ 6 THEN 2
           WHEN SUM(money) BETWEEN 1 + 10 ^ 6 AND 10 ^ 7 THEN 3
           WHEN SUM(money) BETWEEN 1 + 10 ^ 7 AND 10 ^ 8 THEN 4
           WHEN SUM(money) BETWEEN 1 + 10 ^ 8 AND 10 ^ 9 THEN 5
           WHEN SUM(money) BETWEEN 1 + 10 ^ 9 AND 10 ^ 10 THEN 6
           WHEN SUM(money) BETWEEN 1 + 10 ^ 10 AND 10 ^ 11 THEN 7
           WHEN SUM(money) BETWEEN 1 + 10 ^ 11 AND 10 ^ 12 THEN 8
           WHEN SUM(money) BETWEEN 1 + 10 ^ 12 AND 10 ^ 13 THEN 9
           WHEN SUM(money) BETWEEN 1 + 10 ^ 13 AND 10 ^ 14 THEN 10
           WHEN SUM(money) > 10 ^ 14 THEN 11
           END AS rid
FROM tmp_snap
WHERE t_id <= tx1
  AND (t_id_in > tx1 OR t_id_in IS NULL)
  AND a_id IS NOT NULL
  AND money > 0
GROUP BY a_id;
CALL __rid_idx();
$$;

CREATE OR REPLACE PROCEDURE __r1(d0 DATE)
    LANGUAGE sql
AS
$$
    -- R.1: Addr_Num (addrs number to the end of tx); Timing: 12"
DELETE
FROM t_1a_date
WHERE t_1a_date.d = d0
  AND qid = 1;
INSERT INTO t_1a_date (d, qid, rid, val)
SELECT d0,
       1,
       tmp_rid.rid,
       COUNT(*) AS val
FROM tmp_rid
GROUP BY d0, rid;
$$;

CREATE OR REPLACE PROCEDURE __r2(d0 DATE, tx0 INTEGER, tx1 INTEGER)
    LANGUAGE sql
AS
$$
    -- R.2: Addr_Num_Active (addrs number active B2n txs); Timing: 50"
DELETE
FROM t_1a_date
WHERE t_1a_date.d = d0
  AND qid = 2;
INSERT INTO t_1a_date (d, qid, rid, val)
SELECT d0,
       2,
       tmp_rid.rid,
       COUNT(*) AS val
FROM tmp_rid
         INNER JOIN (SELECT DISTINCT a_id
                     FROM tmp_snap
                     WHERE (t_id BETWEEN tx0 AND tx1)
                        OR (t_id_in BETWEEN tx0 AND tx1)) AS active ON tmp_rid.a_id = active.a_id
GROUP BY d0, tmp_rid.rid;
$$;

CREATE OR REPLACE PROCEDURE __r3(d0 DATE, tx1 INTEGER)
    LANGUAGE sql
AS
$$
    -- R.3: Utxo_Num (UTXO numbers to the end of the tx)
    -- Timing:
DELETE
FROM t_1a_date
WHERE t_1a_date.d = d0
  AND qid = 3;
INSERT INTO t_1a_date (d, qid, rid, val)
SELECT d0,
       3,
       tmp_rid.rid,
       COUNT(*) AS num
FROM tmp_rid
         INNER JOIN tmp_snap ON tmp_rid.a_id = tmp_snap.a_id
WHERE t_id <= tx1
  AND (t_id_in > tx1 OR t_id_in IS NULL)
GROUP BY d0, tmp_rid.rid;
$$;

CREATE OR REPLACE PROCEDURE __r4(d0 DATE, tx1 INTEGER)
    LANGUAGE sql
AS
$$
    -- R.4: Utxo_Sum (addrs summs to the end of the tx)
    -- Timing: 1'30"
DELETE
FROM t_1a_date
WHERE t_1a_date.d = d0
  AND qid = 4;
INSERT INTO t_1a_date (d, qid, rid, val)
SELECT d0,
       4,
       tmp_rid.rid,
       SUM(money) AS num
FROM tmp_rid
         INNER JOIN tmp_snap ON tmp_rid.a_id = tmp_snap.a_id
WHERE t_id <= tx1
  AND (t_id_in > tx1 OR t_id_in IS NULL)
GROUP BY d0, tmp_rid.rid;
$$;

CREATE OR REPLACE PROCEDURE __r5(d0 DATE, tx0 INTEGER, tx1 INTEGER)
    LANGUAGE sql
AS
$$
    -- R.5: Vout_Num (vouts number B2n txs); Timing: 20"
DELETE
FROM t_1a_date
WHERE t_1a_date.d = d0
  AND qid = 5;
INSERT INTO t_1a_date (d, qid, rid, val)
SELECT d0,
       5,
       tmp_rid.rid,
       COUNT(*) AS val
FROM tmp_rid
         INNER JOIN tmp_snap ON tmp_rid.a_id = tmp_snap.a_id
WHERE t_id BETWEEN tx0 AND tx1
  AND (t_id_in > tx1 OR t_id_in IS NULL)
GROUP BY d0, tmp_rid.rid;
$$;

CREATE OR REPLACE PROCEDURE __r6(d0 DATE, tx0 INTEGER, tx1 INTEGER)
    LANGUAGE sql
AS
$$
    --- R.6: Vout_Sum (vouts sums B2n txs); Timing: 20"
DELETE
FROM t_1a_date
WHERE t_1a_date.d = d0
  AND qid = 6;
INSERT INTO t_1a_date (d, qid, rid, val)
SELECT d0,
       6,
       tmp_rid.rid,
       SUM(money) AS val
FROM tmp_rid
         INNER JOIN tmp_snap ON tmp_rid.a_id = tmp_snap.a_id
WHERE t_id BETWEEN tx0 AND tx1
  AND (t_id_in > tx1 OR t_id_in IS NULL)
GROUP BY d0, tmp_rid.rid;
$$;

CREATE OR REPLACE PROCEDURE _fill_q1a(d0 DATE, tx0 INTEGER, tx1 INTEGER)
    LANGUAGE sql
AS
$$
CALL _rid_fill(tx1);
CALL __r1(d0);
CALL __r2(d0, tx0, tx1);
CALL __r3(d0, tx1);
CALL __r4(d0, tx1);
CALL __r5(d0, tx0, tx1);
CALL __r6(d0, tx0, tx1);
    -- TRUNCATE TABLE tmp_rid;
$$;

CREATE OR REPLACE FUNCTION __get_date_txs(IN d0 DATE, OUT tx0 INTEGER, OUT tx1 INTEGER)
    LANGUAGE sql
AS
$$
    -- 5_0_0: Prepare const; Timing: 0"
-- Try: return int ARRAY[2]
SELECT DISTINCT MIN(tx.id) AS tx0,
                MAX(tx.id) AS tx1
FROM tx
         INNER JOIN bk ON tx.b_id = bk.id
WHERE DATE(datime) = d0;
$$;

CREATE OR REPLACE FUNCTION __get_date_tx_min(d0 DATE)
    RETURNS INTEGER
    LANGUAGE sql
AS
$$
SELECT DISTINCT MIN(tx.id)
FROM tx
         INNER JOIN bk ON tx.b_id = bk.id
WHERE DATE(datime) = d0;
$$;

CREATE OR REPLACE FUNCTION __get_date_tx_max(d0 DATE)
    RETURNS INTEGER
    LANGUAGE sql
AS
$$
SELECT DISTINCT MAX(tx.id)
FROM tx
         INNER JOIN bk ON tx.b_id = bk.id
WHERE DATE(datime) = d0;
$$;

CREATE OR REPLACE PROCEDURE _dately(d0 DATE, d1 DATE)
    LANGUAGE plpgsql
AS
$$
DECLARE
    d DATE;
BEGIN
    CALL __tbl_c_tmp_snap();
    CALL __tbl_c_tmp_rid();
    CALL _snap_fill(__get_date_tx_min(d0), __get_date_tx_max(d1));
    FOR d IN SELECT * FROM generate_series(d0, d1, '1 day')
        LOOP
            CALL _fill_q1a(d, __get_date_tx_min(d), __get_date_tx_max(d));
        END LOOP;
END;
$$;
COMMENT ON PROCEDURE _dately(DATE, DATE) IS 'Recalc q1a for a dates d0..d1
@ver: 20220610.16.15';

CREATE OR REPLACE PROCEDURE _daily(d DATE)
    LANGUAGE sql
AS
$$
/*
 Timing: 10'35..10'45" (vout, 2022-01-01)
 */
    CALL _dately(d, d);
$$;
COMMENT ON PROCEDURE _daily(DATE) IS 'Recalc q1a for a day
@ver: 20220610.16.20';

CREATE OR REPLACE PROCEDURE _monthly(y INTEGER, m INTEGER)
    LANGUAGE sql
AS
$$
    CALL _dately(make_date(y, m, 1), __dom_max(make_date(y, m, 1)));
END;
$$;
COMMENT ON PROCEDURE _monthly(INTEGER, INTEGER) IS 'Recalc q1a for a month
@ver: 20220610.16.20';

CREATE OR REPLACE PROCEDURE _yearly(y INTEGER)
    LANGUAGE sql
AS
$$
    CALL _dately(make_date(y, 1, 1), make_date(y, 12, 31));
$$;
COMMENT ON PROCEDURE _yearly(INTEGER) IS 'Recalc q1a for a year
@ver: 20220610.16.25';

-- CALL _daily('2022-03-30');
-- time psql -q -c "CALL _daily('2022-01-01');" <db> <user>
-- CALL _monthly(2022, 3);
