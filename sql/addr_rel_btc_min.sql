-- {
-- "name": "buratinos_min_cent",
-- "note": "Get top [num] addresses with max lost (%) in period [fromdate]..[todate].",
-- "required": ["DATE0", "DATE1", "NUM"],
-- "header": ["a_id", "address", "profit, %"],
-- "output": "columns name:typ"
-- }
SELECT
  b.a_id AS a_id,
  addresses.a_list AS addr,
  b.itogo AS itogo0,
  e.itogo AS itogo1,
  ROUND(b.itogo/e.itogo-1, 0) AS profit
FROM (
  SELECT a_id, SUM(satoshi) AS itogo
  FROM txo_real
  WHERE
    (date0 < '$DATE0')
    AND (date1 >= '$DATE0' OR date1 IS NULL)
  GROUP BY a_id
) AS b INNER JOIN (
  SELECT a_id, SUM(satoshi) AS itogo
  FROM txo_real
  WHERE
    (date0 <= '$DATE1')
    AND (date1 > '$DATE1' OR date1 IS NULL)
  GROUP BY a_id
  HAVING SUM(satoshi) > 0
) AS e ON b.a_id = e.a_id
JOIN addresses ON e.a_id = addresses.a_id
ORDER BY profit DESC
LIMIT $NUM;