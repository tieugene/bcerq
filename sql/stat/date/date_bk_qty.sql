-- date_bk_qty: bk count by date
-- 0"
SELECT
  DATE(datime) AS d,
  COUNT(*) AS qty
FROM
  bk
WHERE
 DATE(datime) BETWEEN '2017-01-01' AND '2017-01-10'
GROUP BY d
ORDER BY d;