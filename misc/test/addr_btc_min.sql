-- {
-- "name": "buratinos_btc_min",
-- "note": "Get top [num] addresses with max lost (BTC) in period [fromdate]..[todate].",
-- "required": ["DATE0", "DATE1", "NUM"],
-- "header": ["a_id", "address", "loss, ㋛"],
-- "output": "columns name:typ (a_id:int,addr:str,satoshi:Decimal())"
-- }
SELECT
    e.a_id AS a_id,
    addresses.a_list AS addr,
    COALESCE(e.itogo, 0)-b.itogo AS profit
FROM (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo_real
    WHERE
        (date0 < '2012-01-01')
        AND (date1 >= '2012-01-01' OR date1 IS NULL)
    GROUP BY a_id
) AS b LEFT JOIN (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo_real
    WHERE
        (date0 <= '2012-08-31')
        AND (date1 > '2012-08-31' OR date1 IS NULL)
    GROUP BY a_id
) AS e ON b.a_id = e.a_id
INNER JOIN addresses ON e.a_id = addresses.a_id
ORDER BY profit ASC
LIMIT 50;