-- bk_so: Spent txo stat by bk
-- 11'27" (desc lim 20)
SELECT
  tx.b_id AS b_id,
  COUNT(*) AS so_num,
  COUNT(*) FILTER (WHERE addr.qty = 1 AND vout.money > 0) AS so_num_job,
  SUM(money) AS so_sum,
  SUM(money) FILTER (WHERE addr.qty = 1) AS so_sum_job,
  MAX(money) AS so_max
FROM vout
  INNER JOIN tx ON vout.t_id_in = tx.id
  LEFT JOIN tx AS tx_o ON vout.t_id = tx_o.id
  LEFT JOIN addr ON vout.a_id = addr.id
WHERE vout.t_id_in IS NOT NULL
  AND tx_o.b_id < tx.b_id
  AND tx.b_id < $1
GROUP BY tx.b_id;
