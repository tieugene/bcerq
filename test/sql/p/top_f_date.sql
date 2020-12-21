-- top.full (raw, date())
SELECT
    addr.name as name,
    itogo
FROM (
    SELECT
        a_id,
        SUM(money) as itogo
    FROM (
    SELECT
      a_id,
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
) AS txo
    WHERE
        (date0 < '2013-06-01')
        AND (date1 >= '2013-06-01' OR date1 IS NULL)
    GROUP BY a_id
    ORDER BY itogo DESC
    LIMIT 50
) AS tops INNER JOIN addr ON tops.a_id = addr.id;
