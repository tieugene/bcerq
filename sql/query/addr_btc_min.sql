-- {
-- "name": "addr_btc_min",
-- "note": "Top [num] addresses by lost (₿) in period [fromdate]..[todate].",
-- "required": ["DATE0", "DATE1", "NUM"],
-- "header": ["a_id", "address", "begin data", "end data", "abs loss"],
-- "output": "columns name:typ (a_id:int,addr:str,satoshi:Decimal())"
-- }
SELECT
    e.a_id AS a_id,
    addresses.a_list AS addr,
    b.itogo AS itogo0,
    e.itogo AS itogo1,
    COALESCE(e.itogo, 0)-b.itogo AS profit
FROM (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo
    WHERE
        (date0 < '$DATE0')
        AND (date1 >= '$DATE0' OR date1 IS NULL)
    GROUP BY a_id
) AS b LEFT JOIN (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo
    WHERE
        (date0 <= '$DATE1')
        AND (date1 > '$DATE1' OR date1 IS NULL)
    GROUP BY a_id
) AS e ON b.a_id = e.a_id
INNER JOIN addresses ON e.a_id = addresses.a_id
ORDER BY profit ASC
LIMIT $NUM;