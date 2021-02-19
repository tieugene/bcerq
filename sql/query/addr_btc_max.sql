-- {
-- "name": "addr_btc_max",
-- "note": "Top [num] addresses by gain (₿) in period [fromdate]..[todate].",
-- "required": ["DATE0", "DATE1", "NUM"],
-- "header": ["a_id", "address", "∑₀, ㋛", "∑₁, ㋛", "gain, ㋛"],
-- "output": "columns name:typ (a_id:int,addr:str,satoshi:Decimal())"
-- }
SELECT
    a_id,
    addr.name->>0 AS address,
    itogo0,
    itogo1,
    profit
FROM (
    SELECT
        e.a_id AS a_id,
        b.itogo AS itogo0,
        e.itogo AS itogo1,
        e.itogo-COALESCE(b.itogo, 0) AS profit
    FROM (
        SELECT a_id, SUM(money) AS itogo
        FROM txo
        WHERE
            (date0 < '$DATE0')
            AND (date1 >= '$DATE0' OR date1 IS NULL)
        GROUP BY a_id
    ) AS b RIGHT JOIN (
        SELECT a_id, SUM(money) AS itogo
        FROM txo
        WHERE
            (date0 <= '$DATE1')
            AND (date1 > '$DATE1' OR date1 IS NULL)
        GROUP BY a_id
    ) AS e ON b.a_id = e.a_id
    ORDER BY profit DESC
    LIMIT $NUM
) INNER JOIN addr ON a_id = addr.a_id;
