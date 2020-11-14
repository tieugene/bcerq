-- all UTXO by months
WITH months AS (
 SELECT * FROM GENERATE_SERIES('2009-02-01'::DATE, '2012-09-01'::DATE, '1 month') AS d0
)
SELECT
 DATE(months.d0) AS mon,
 SUM(satoshi) AS money
FROM txo_all, months
WHERE
 (txo_all.date0 < months.d0)
 AND (txo_all.date1 >= months.d0 OR txo_all.date1 IS NULL)
GROUP By months.d0
ORDER BY months.d0;
