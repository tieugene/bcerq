-- {
-- "name": "alist_btc_gt",
-- "note": "Balance change of addresses [alist] in period [fromdate]..[todate] which gain > [num] ₿.",
-- "required": ["DATE0", "DATE1", "NUM", "ALIST"],
-- "header": ["a_id", "address", "∑₀, ₿", "∑₁, ₿", "Δ∑, ₿"],
-- "output": "columns name:typ (a_id:int,addr:str,satoshi:Decimal())"
-- }
SELECT
    a.a_id AS a_id,
    a.a_list AS addr,
    b.itogo AS itogo0,
    e.itogo AS itogo1,
    COALESCE(e.itogo, 0) - COALESCE(b.itogo, 0) AS profit_b
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
WHERE (e.itogo - COALESCE(b.itogo, 0)) > $NUM
ORDER BY profit_b DESC;