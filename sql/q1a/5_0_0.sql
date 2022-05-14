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
