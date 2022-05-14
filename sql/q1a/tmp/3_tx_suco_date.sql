-- 3_tx_suco_date.sql: Like 3_tx_suco but use date and const
DROP TABLE IF EXISTS today;
CREATE TEMP TABLE today AS
SELECT
    DATE(datime) AS d,
    MIN(tx.id) AS tx0,
    MAX(tx.id) AS tx1
FROM tx
INNER JOIN bk ON tx.b_id = bk.id
WHERE DATE(datime) = '2022-03-31'
GROUP BY d;
--
-- WITH consts (d, tx0, tx1) AS (SELECT DISTINCT d, tx0, tx1 FROM today)
WITH consts (d, tx0, tx1) AS (VALUES ('2022-03-31', 721765790, 722043870))
SELECT
  CASE
    WHEN total BETWEEN 1 AND 10^5 THEN 1
    WHEN total BETWEEN 1+10^5 AND 10^6 THEN 2
    WHEN total BETWEEN 1+10^6 AND 10^7 THEN 3
    WHEN total BETWEEN 1+10^7 AND 10^8 THEN 4
    WHEN total BETWEEN 1+10^8 AND 10^9 THEN 5
    WHEN total BETWEEN 1+10^9 AND 10^10 THEN 6
    WHEN total BETWEEN 1+10^10 AND 10^11 THEN 7
    WHEN total BETWEEN 1+10^11 AND 10^12 THEN 8
    WHEN total BETWEEN 1+10^12 AND 10^13 THEN 9
    WHEN total BETWEEN 1+10^13 AND 10^14 THEN 10
    WHEN total > 10^14 THEN 11
  END AS qid,
  COUNT(*),
  SUM(total)
FROM (
  SELECT
    consts.d,
    a_id,
    SUM(money) AS total
  FROM
    vout, consts
  WHERE
    t_id <= consts.tx1 AND
    (t_id_in > consts.tx1 OR t_id_in IS NULL) AND
    a_id IS NOT NULL AND
    money > 0
  GROUP BY
    d, a_id
) AS buratinos
GROUP BY 1
ORDER BY 1;
