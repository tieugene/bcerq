-- date_txi: txo in stat by date
-- 2'04"
SELECT
  date1 AS d,
  COUNT(*) AS i_num,
  MAX(money) AS i_max,
  SUM(money) AS i_sum
FROM txo
WHERE date1 IS NOT NULL
GROUP BY d
ORDER BY d DESC
LIMIT 20
;