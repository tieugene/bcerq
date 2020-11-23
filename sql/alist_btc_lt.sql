-- {
-- "name": "alist_btc_lt",
-- "note": "Balance change of addresses [alist] in period [fromdate]..[todate] which loss > [num] ₿.",
-- "required": ["DATE0", "DATE1", "NUM", "ALIST"],
-- "header": ["a_id", "address", "Δ∑, ₿", "∑₀, ₿", "∑₁, ₿"],
-- "output": "columns name:typ (a_id:int,addr:str,satoshi:Decimal())"
-- }
SELECT
    a.a_id AS a_id,
    a.a_list AS addr,
    COALESCE(e.itogo, 0) - COALESCE(b.itogo, 0) AS profit_b,
    b.itogo AS itogo0,
    e.itogo AS itogo1
FROM (
    SELECT a_id, a_list
    FROM addresses
    WHERE a_id IN ($ALIST)
) AS a
INNER JOIN (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo
    WHERE
        (date0 < '$DATE0')
        AND (date1 >= '$DATE0' OR date1 IS NULL)
    GROUP BY a_id
    HAVING SUM(satoshi) > 0
) AS b ON a.a_id = b.a_id
INNER JOIN (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo
    WHERE
        (date0 <= '$DATE1')
        AND (date1 > '$DATE1' OR date1 IS NULL)
    GROUP BY a_id
    HAVING SUM(satoshi) > 0
) AS e ON a.a_id = e.a_id
WHERE (b.itogo - COALESCE(e.itogo, 0)) > $NUM
ORDER BY profit_c ASC;