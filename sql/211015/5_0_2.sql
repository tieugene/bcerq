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
