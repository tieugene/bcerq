-- date_vi: vins stat by bk (?)
-- 01:01:35 (note: 'Where ... is not null` is very important)
SELECT
  DATE(bk.datime) AS d,
  COUNT(vout.*) AS i_num,
  COUNT(vout.*) FILTER (WHERE addr.qty = 1) AS i_single_num,
  COUNT(vout.*) FILTER (WHERE addr.qty > 1) AS i_multi_num,
  COUNT(vout.*) FILTER (WHERE vout.a_id IS NULL) AS i_none_num,
  COUNT(vout.*) FILTER (WHERE vout.money = 0) AS i_zero_num,
  MAX(vout.money) AS i_max,
  SUM(vout.money) AS i_sum,
  SUM(vout.money) FILTER (WHERE addr.qty = 1) AS i_single_sum,
  SUM(vout.money) FILTER (WHERE addr.qty > 1) AS i_multi_sum,
  SUM(vout.money) FILTER (WHERE vout.a_id IS NULL) AS i_none_sum
FROM vout
  JOIN tx ON vout.t_id_in = tx.id
  JOIN bk ON tx.b_id = bk.id
  LEFT JOIN addr ON vout.a_id = addr.id
WHERE vout.t_id_in IS NOT NULL
GROUP BY d
ORDER BY d DESC
LIMIT 20
;