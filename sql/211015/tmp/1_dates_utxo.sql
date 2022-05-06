-- 1_dates_utxo: UTXO (qty, sum) by dates
-- 8'20"/10
WITH dates AS (
  SELECT generate_series('2017-01-01'::DATE, '2017-01-10'::DATE, '1 day'::INTERVAL)::date AS d
)
SELECT
  dates.d AS d,
  COUNT(txo.*) AS qty,
  SUM(txo.money) AS total
FROM
  dates
JOIN txo ON
  txo.date0 <= dates.d AND
  (txo.date1 > dates.d OR txo.date1 IS NULL)
GROUP BY d
ORDER BY d;
