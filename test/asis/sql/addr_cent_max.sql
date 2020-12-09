SELECT
    b.a_id AS a_id,
    addresses.a_list AS addr,
    ROUND(e.itogo/b.itogo-1, 0) AS profit,
    b.itogo AS itogo0,
    e.itogo AS itogo1
FROM (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo_real
    WHERE
        (date0 < '2012-01-01')
        AND (date1 >= '2012-01-01' OR date1 IS NULL)
    GROUP BY a_id
    HAVING SUM(satoshi) > 0
) AS b INNER JOIN (
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
