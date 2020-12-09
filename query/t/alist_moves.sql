-- {
-- "name": "alist_moves",
-- "note": " Balance change of addresses [alist] in period [fromdate]..[todate].",
-- "required": ["DATE0", "DATE1", "ALIST"],
-- "header": ["a_id", "address", "∑₀, ₿", "∑₁, ₿", "Δ∑, ₿", "Δ∑, %"],
-- "output": "columns name:typ (a_id:int,addr:str,satoshi:Decimal())"
-- }
SELECT
    a.a_id AS a_id,
    a.a_list AS addr,
    COALESCE(b.itogo, 0) AS itogo0,
    COALESCE(e.itogo, 0) AS itogo1,
    COALESCE(e.itogo, 0) - COALESCE(b.itogo, 0) AS profit_b,
    CASE WHEN
           b.itogo IS NULL
        OR b.itogo = 0
        OR e.itogo IS NULL
        OR e.itogo = 0
    THEN
        NULL
    ELSE
        CASE WHEN
            e.itogo > b.itogo
        THEN
            (e.itogo/b.itogo - 1) * 100
        ELSE
            (1 - b.itogo/e.itogo) * 100
        END
    END AS profit_c
FROM (
    SELECT a_id, a_list
    FROM addresses
    WHERE a_id IN ($ALIST)
) AS a
LEFT JOIN (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo
    WHERE
        (date0 < '$DATE0')
        AND (date1 >= '$DATE0' OR date1 IS NULL)
    GROUP BY a_id
) AS b ON a.a_id = b.a_id
LEFT JOIN (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo
    WHERE
        (date0 <= '$DATE1')
        AND (date1 > '$DATE1' OR date1 IS NULL)
    GROUP BY a_id
) AS e ON a.a_id = e.a_id
ORDER BY addr;