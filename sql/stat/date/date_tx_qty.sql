-- date_tx_qty: tx count by date
-- 0"
SELECT
  DATE(bk.datime) AS d,
  COUNT(*) AS qty
FROM tx JOIN bk ON tx.b_id = bk.id
WHERE
 DATE(bk.datime) BETWEEN '2017-01-01' AND '2017-01-10'
GROUP BY d
ORDER BY d;