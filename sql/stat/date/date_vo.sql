-- o_by_date: vouts stat by date
-- 01:04'22"
SELECT
  DATE(bk.datime) AS d,
  COUNT(vout.*) AS o_num,
  COUNT(vout.*) FILTER (WHERE addr.qty = 1) AS o_single_num,
  COUNT(vout.*) FILTER (WHERE addr.qty > 1) AS o_multi_num,
  COUNT(vout.*) FILTER (WHERE vout.a_id IS NULL) AS o_none_num,
  COUNT(vout.*) FILTER (WHERE vout.money = 0) AS o_zero_num,
  MAX(vout.money) AS o_max,
  SUM(vout.money) AS o_sum,
  SUM(vout.money) FILTER (WHERE addr.qty = 1) AS o_single_sum,
  SUM(vout.money) FILTER (WHERE addr.qty > 1) AS o_multi_sum,
  SUM(vout.money) FILTER (WHERE vout.a_id IS NULL) AS o_none_sum
FROM vout
  JOIN tx ON vout.t_id = tx.id
  JOIN bk ON tx.b_id = bk.id
  LEFT JOIN addr ON vout.a_id = addr.id
GROUP BY d
ORDER BY d DESC
LIMIT 20
;