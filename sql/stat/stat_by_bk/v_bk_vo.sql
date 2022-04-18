-- bk_vo: vouts stat by bk
-- 30"..5'27"@20 / 01:08'@450k (== view | order lim)
SELECT
  tx.b_id AS b_id,
  COUNT(*) AS vo_num,
  COUNT(*) FILTER (WHERE addr.qty = 1 AND money > 0) AS vo_num_job,
  SUM(money) AS vo_sum,
  SUM(money) FILTER (WHERE addr.qty = 1) AS vo_sum_job,
  MAX(money) AS vo_max
FROM vout
  INNER JOIN tx ON vout.t_id = tx.id
  LEFT JOIN addr ON vout.a_id = addr.id
WHERE tx.b_id < $1
GROUP BY b_id;
