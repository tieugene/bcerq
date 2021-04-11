-- {
-- "name": "alist_cnt_lt",
-- "note": "Balance change of addresses [alist] in period [fromdate]..[todate] which loss > [num] %.",
-- "required": ["DATE0", "DATE1", "NUM", "ALIST"],
-- "header": ["a_id", "address", "begin data, ₿", "end data, ₿", "abs loss >N, ₿", "rel los >N, %"],
-- "output": "columns name:typ (a_id:int,addr:str,satoshi:Decimal())"
-- }
SELECT
    a.id AS a_id,
    a.name AS address,
    b.itogo AS itogo0,
    e.itogo AS itogo1,
    COALESCE(e.itogo, 0) - COALESCE(b.itogo, 0) AS profit_b,
    ROUND((1 - b.itogo/e.itogo) * 100, 0) AS profit_c
FROM (
    SELECT id, name
    FROM addr
    WHERE id IN ($ALIST)
) AS a
INNER JOIN (
    SELECT a_id, SUM(money) AS itogo
    FROM txo
    WHERE
        (date0 < '$DATE0')
        AND (date1 >= '$DATE0' OR date1 IS NULL)
    GROUP BY a_id
    HAVING SUM(money) > 0
) AS b ON a.id = b.a_id
INNER JOIN (
    SELECT a_id, SUM(money) AS itogo
    FROM txo
    WHERE
        (date0 <= '$DATE1')
        AND (date1 > '$DATE1' OR date1 IS NULL)
    GROUP BY a_id
    HAVING SUM(money) > 0
) AS e ON a.id = e.a_id
WHERE (b.itogo/e.itogo-1)*100 > $NUM
ORDER BY profit_c ASC, a_id ASC;
