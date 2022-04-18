-- date_txo: txo out stat by date
-- 1'55"
SELECT
  date0 AS d,
  COUNT(*) AS o_num,
  MAX(money) AS o_max,
  SUM(money) AS o_sum
FROM txo
GROUP BY d
ORDER BY d DESC
LIMIT 20
;