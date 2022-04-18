-- bk_lo: Loopbacks stat by bk
-- 0" (desc lim 20)
SELECT
  tx.b_id AS b_id,
  COUNT(*) AS lo_num,
  COUNT(*) FILTER (WHERE addr.qty = 1 AND vout.money > 0) AS lo_num_job,
  SUM(money) AS lo_sum,
  SUM(money) FILTER (WHERE addr.qty = 1) AS lo_sum_job,
  MAX(money) AS lo_max
FROM vout
  INNER JOIN tx ON vout.t_id = tx.id
  INNER JOIN tx AS tx_i ON vout.t_id_in = tx_i.id
  LEFT JOIN addr ON vout.a_id = addr.id
WHERE tx.b_id = tx_i.b_id
  AND tx.b_id < $1
GROUP BY tx.b_id;
