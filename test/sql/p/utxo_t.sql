-- utxo.tiny
SELECT
 months.d0 AS mon,
 SUM(money) AS money
FROM (
 SELECT DISTINCT date0 AS d0 FROM vout WHERE EXTRACT(DAY FROM date0) = 1
) AS months, (
    SELECT
      money,
      date0,
      date1
    FROM vout
) AS txo_all
WHERE
 (txo_all.date0 < months.d0)
 AND (txo_all.date1 >= months.d0 OR txo_all.date1 IS NULL)
GROUP By months.d0
ORDER BY months.d0;
