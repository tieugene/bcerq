-- 3. Count addrs at a date by burtinity
-- 47"
SELECT
  CASE
    WHEN total = 0 THEN 0
    WHEN total BETWEEN 1 AND 10^5 THEN 1
    WHEN total BETWEEN 1+10^5 AND 10^6 THEN 2
    WHEN total BETWEEN 1+10^6 AND 10^7 THEN 3
    WHEN total BETWEEN 1+10^7 AND 10^8 THEN 4
    WHEN total BETWEEN 1+10^8 AND 10^9 THEN 5
    WHEN total BETWEEN 1+10^9 AND 10^10 THEN 6
    WHEN total BETWEEN 1+10^10 AND 10^11 THEN 7
    WHEN total BETWEEN 1+10^11 AND 10^12 THEN 8
    WHEN total BETWEEN 1+10^12 AND 10^13 THEN 9
    WHEN total > 10^13 THEN 10
  END,
  COUNT(*)
FROM (
  SELECT
    a_id,
    SUM(money) AS total
  FROM
    txo
  WHERE
    date0 <= '2016-12-31' AND
    (date1 > '2016-12-31' OR date1 IS NULL)
  GROUP BY
    a_id
) AS buratinos
GROUP BY 1
ORDER BY 1;
