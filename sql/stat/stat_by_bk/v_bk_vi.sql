-- bk_vi: vins stat by bk
-- 2'04"..6'42"@20 / 01:08'@450k
-- Note: 'Where t_id_in is not null` is very important
SELECT
  tx.b_id AS b_id,
  COUNT(*) AS vi_num,
  COUNT(*) FILTER (WHERE addr.qty = 1 AND vout.money > 0) AS vi_num_job,
  SUM(money) AS vi_sum,
  SUM(money) FILTER (WHERE addr.qty = 1) AS vi_sum_job,
  MAX(money) AS vi_max
FROM vout
  INNER JOIN tx ON vout.t_id_in = tx.id
  LEFT JOIN addr ON vout.a_id = addr.id
WHERE vout.t_id_in IS NOT NULL
  AND tx.b_id < $1
GROUP BY b_id;
