-- bk_uo: (Newly created) utxo stat by bk
-- 5'38" (desc lim 20)
SELECT
  tx.b_id AS b_id,
  COUNT(*) AS uo_num,
  COUNT(*) FILTER (WHERE addr.qty = 1 AND vout.money > 0) AS uo_num_job,
  SUM(money) AS uo_sum,
  SUM(money) FILTER (WHERE addr.qty = 1) AS uo_sum_job,
  MAX(money) AS uo_max
FROM vout
  INNER JOIN tx ON vout.t_id = tx.id
  LEFT JOIN tx AS tx_i ON vout.t_id_in = tx_i.id
  LEFT JOIN addr ON vout.a_id = addr.id
WHERE (vout.t_id_in IS NULL OR tx_i.b_id > tx.b_id)
  AND tx.b_id < $1
GROUP BY tx.b_id;
