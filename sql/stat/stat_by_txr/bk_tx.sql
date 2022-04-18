-- bk_tx: list of bk tx
-- 0"
SELECT
  b_id,
  MIN(id) AS tx0,
  MAX(id) AS tx1
FROM tx
GROUP BY b_id;
