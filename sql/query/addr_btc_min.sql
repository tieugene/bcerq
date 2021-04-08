-- {
-- "name": "addr_btc_min",
-- "note": "Top [num] addresses by lost (₿) in period [fromdate]..[todate].",
-- "required": ["DATE0", "DATE1", "NUM"],
-- "header": ["a_id", "address", "begin data", "end data", "abs loss"],
-- "output": "columns name:typ (a_id:int,addr:str,satoshi:Decimal())"
-- }
SELECT
    a_id,
    addr.name AS address,
    itogo0,
    itogo1,
    profit
FROM (
    SELECT
        b.a_id AS a_id,
        b.itogo AS itogo0,
        e.itogo AS itogo1,
        COALESCE(e.itogo, 0)-b.itogo AS profit
    FROM (
        SELECT a_id, SUM(money) AS itogo
        FROM txo
        WHERE
            (date0 < '$DATE0')
            AND (date1 >= '$DATE0' OR date1 IS NULL)
        GROUP BY a_id
    ) AS b LEFT JOIN (
        SELECT a_id, SUM(money) AS itogo
        FROM txo
        WHERE
            (date0 <= '$DATE1')
            AND (date1 > '$DATE1' OR date1 IS NULL)
        GROUP BY a_id
    ) AS e ON b.a_id = e.a_id
    ORDER BY profit ASC, a_id ASC
    LIMIT $NUM
) AS data INNER JOIN addr ON a_id = addr.id;
