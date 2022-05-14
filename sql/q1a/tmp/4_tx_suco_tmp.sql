-- 4. 4_tx_suco_tmp: get suco (cum and count) using tmp buratinity table
-- TODO: replace hardcoded TXs with 'WITH txo AS (SELECT ... FROM today)
-- TODO: filter today = остатки на конец + обороты за день
-- C: create table
DROP TABLE IF EXISTS t_qid;
CREATE TEMP TABLE t_qid AS
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
    END AS qid
FROM
    vout
WHERE
    t_id <= 183759444 AND
    (t_id_in > 183759444 OR t_id_in IS NULL) AND
    a_id IS NOT NULL AND
    money > 0
GROUP BY
    a_id;
-- I: idx it
ALTER TABLE t_qid ADD CONSTRAINT t_qid_pkey PRIMARY KEY (a_id);
CREATE INDEX IF NOT EXISTS idx_t_qid_qid ON t_qid (qid);
-- R: Reports
--- R.1: ✓ Addr_Num (addrs number to the end of tx)
SELECT
  COUNT(*) AS num
FROM t_qid
GROUP BY qid
ORDER BY qid;
--- R.2: ✓ Addr_Sum (addrs summs to the end of the tx)
SELECT
  t_qid.qid AS qid,
  SUM(money) AS num
FROM t_qid
INNER JOIN vout ON t_qid.a_id = vout.a_id
WHERE
    t_id <= 183759444 AND
    (t_id_in > 183759444 OR t_id_in IS NULL)
GROUP BY t_qid.qid
ORDER BY qid;
--- R.3: ✓ Addr_Num_Active (addrs number active B2n txs)
SELECT
  t_qid.qid AS qid,
  COUNT(*) AS num
FROM t_qid
INNER JOIN (
    SELECT
        DISTINCT a_id
    FROM
        vout
    WHERE
        (t_id BETWEEN 183758064 AND 183759444) OR
        (t_id_in BETWEEN 183758064 AND 183759444)
    ) AS active ON t_qid.a_id = active.a_id
GROUP BY t_qid.qid
ORDER BY qid;
--- R.4: ✓ Vout_Num (vouts number B2n txs)
SELECT
  t_qid.qid AS qid,
  COUNT(*) AS num
FROM t_qid
INNER JOIN vout ON t_qid.a_id = vout.a_id
WHERE
    t_id BETWEEN 183758064 AND 183759444
GROUP BY t_qid.qid
ORDER BY qid;
--- R.5: ✓ Vout_Sum (vouts sums B2n txs)
SELECT
  t_qid.qid AS qid,
  SUM(money) AS num
FROM t_qid
INNER JOIN vout ON t_qid.a_id = vout.a_id
WHERE
    t_id BETWEEN 183758064 AND 183759444
GROUP BY t_qid.qid
ORDER BY qid;
--- R.6: ✓ Vin_Num (vins number B2n txs)
SELECT
  t_qid.qid AS qid,
  COUNT(*) AS num
FROM t_qid
INNER JOIN vout ON t_qid.a_id = vout.a_id
WHERE
    t_id_in BETWEEN 183758064 AND 183759444
GROUP BY t_qid.qid
ORDER BY qid;
--- R.x: ✓ Vloop_Num (vloops number of txs)
SELECT
  t_qid.qid AS qid,
  COUNT(*) AS num
FROM t_qid
INNER JOIN vout ON t_qid.a_id = vout.a_id
WHERE
    (t_id BETWEEN 183758064 AND 183759444) AND
    (t_id_in BETWEEN 183758064 AND 183759444)
GROUP BY t_qid.qid
ORDER BY qid;
