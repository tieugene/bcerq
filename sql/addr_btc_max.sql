-- {
-- "name": "buratinos_btc_max",
-- "note": "Get top [num] addresses with max profit (BTC) in period [fromdate]..[todate].",
-- "required": ["DATE0", "DATE1", "NUM"],
-- "header": ["a_id", "address", "profit, ₿"],
-- "output": "columns name:typ (a_id:int,addr:str,satoshi:Decimal())"
-- }
SELECT
    e.a_id AS a_id,
    addresses.a_list AS addr,
    e.itogo-COALESCE(b.itogo, 0) AS profit
FROM (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo_real
    WHERE
        (date0 < '$DATE0')
        AND (date1 >= '$DATE0' OR date1 IS NULL)
    GROUP BY a_id
) AS b RIGHT JOIN (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo_real
    WHERE
        (date0 <= '$DATE1')
        AND (date1 > '$DATE1' OR date1 IS NULL)
    GROUP BY a_id
) AS e ON b.a_id = e.a_id
JOIN addresses ON e.a_id = addresses.a_id
ORDER BY profit DESC
LIMIT $NUM;