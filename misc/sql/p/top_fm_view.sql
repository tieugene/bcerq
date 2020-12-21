-- top.full/midi (view)
SELECT
    addr.name as name,
    itogo
FROM (
    SELECT
        a_id,
        sum(money) as itogo
    FROM txo
    WHERE
        (date0 < '2013-06-01')
        AND (date1 >= '2013-06-01' OR date1 IS NULL)
    GROUP BY a_id
    ORDER BY itogo DESC
    LIMIT 50
) AS tops INNER JOIN addr ON tops.a_id = addr.id;
