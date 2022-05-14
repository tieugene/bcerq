-- 1. UTXO (qty, sum) at a date
-- 14"
SELECT COUNT(*), SUM(money) FROM (
SELECT
  a_id,
  money
FROM
  txo
WHERE
  date0 <= '2017-01-01' AND
  (date1 > '2017-01-01' OR date1 IS NULL)
) AS utxo;
