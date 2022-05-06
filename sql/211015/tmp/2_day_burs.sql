-- 2. Buratinos (qty, sum) at a date
-- 28"
SELECT COUNT(*) FROM (
SELECT
  a_id,
  SUM(money) AS total
FROM
  txo
WHERE
  date0 <= '2017-01-01' AND
  (date1 > '2017-01-01' OR date1 IS NULL)
GROUP BY a_id
) AS buratinos;
