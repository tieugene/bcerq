-- utxo.full (raw, date())
SELECT
 months.d0 AS mon,
 SUM(money) AS money
FROM (
 SELECT DISTINCT DATE(datime) AS d0 FROM bk WHERE EXTRACT(DAY FROM datime) = 1
) AS months, (
    SELECT
      vout.money AS money,
      DATE(bk0.datime) AS date0,
      DATE(tx1.datime) AS date1
    FROM vout
    INNER JOIN tx AS tx0 ON
      vout.t_id = tx0.id
    INNER JOIN bk AS bk0 ON
      tx0.b_id = bk0.id
    LEFT JOIN (
      SELECT
        tx.id AS id,
        bk.datime AS datime
      FROM tx
      INNER JOIN bk ON
      tx.b_id = bk.id
    ) AS tx1 ON
      vout.t_id_in = tx1.id
) AS txo_all
WHERE
 (txo_all.date0 < months.d0)
 AND (txo_all.date1 >= months.d0 OR txo_all.date1 IS NULL)
GROUP By months.d0
ORDER BY months.d0;
