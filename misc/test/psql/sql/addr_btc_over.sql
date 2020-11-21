SELECT
    txo.a_id AS a_id,
    addresses.a_list as addr,
    itogo
FROM (
    SELECT a_id, sum(satoshi) as itogo
    from txo
    WHERE
        (date0 < '2012-08-31')
        AND (date1 >= '2012-08-31' OR date1 IS NULL)
    GROUP BY a_id
    HAVING SUM(satoshi) >= 1000000000000
) AS txo INNER JOIN addresses ON txo.a_id = addresses.a_id
ORDER BY itogo DESC, a_id ASC;
