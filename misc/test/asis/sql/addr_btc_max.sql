SELECT
    e.a_id AS a_id,
    addresses.a_list AS addr,
    e.itogo-COALESCE(b.itogo, 0) AS profit
FROM (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo_real
    WHERE
        (date0 < '2012-01-01')
        AND (date1 >= '2012-01-01' OR date1 IS NULL)
    GROUP BY a_id
) AS b RIGHT JOIN (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo_real
    WHERE
        (date0 <= '2012-08-31')
        AND (date1 > '2012-08-31' OR date1 IS NULL)
    GROUP BY a_id
) AS e ON b.a_id = e.a_id
INNER JOIN addresses ON e.a_id = addresses.a_id
ORDER BY profit DESC, a_id ASC
LIMIT 50;
