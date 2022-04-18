-- bk: list of blocks with extra attributes
-- 0"
SELECT
  bk.id AS b_id,
  DATE(bk.datime) AS d,
  bk.id/210000 AS edge,
  5000000000>>(bk.id/210000) AS price,
  (((1<<((bk.id/210000)+1))-2)*210000+(bk.id%210000)+1)*(5000000000>>(bk.id/210000)) AS total,
  (SELECT COUNT(*) FROM tx WHERE tx.b_id = bk.id) AS tx_num
FROM bk
WHERE bk.id < $1;
