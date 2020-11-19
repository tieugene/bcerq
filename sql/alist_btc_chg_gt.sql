-- {
-- "name": "alist_btc_chg_gt",
-- "note": "Get balance change (₿) of addresses in [list] in period [fromdate]..[todate] which increased > [num] %.",
-- "required": ["DATE0", "DATE1", "NUM", "ALIST"],
-- "header": ["a_id", "address", "profit, %", "∑0, ₿", "∑1, ₿"],
-- "output": "columns name:typ (a_id:int,addr:str,satoshi:Decimal())"
-- }
SELECT
    a.a_id AS a_id,
    a.a_list AS addr,
    ROUND((e.itogo/b.itogo - 1) * 100, 0) AS profit,
    b.itogo AS itogo0,
    e.itogo AS itogo1
FROM (
    SELECT a_id, a_list
    FROM addresses
    WHERE a_id IN ($ALIST)
) AS a
INNER JOIN (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo_real
    WHERE
        (date0 < '$DATE0')
        AND (date1 >= '$DATE0' OR date1 IS NULL)
    GROUP BY a_id
    HAVING SUM(satoshi) > 0
) AS b ON a.a_id = b.a_id
INNER JOIN (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo_real
    WHERE
        (date0 <= '$DATE1')
        AND (date1 > '$DATE1' OR date1 IS NULL)
    GROUP BY a_id
    HAVING SUM(satoshi) > 0
) AS e ON a.a_id = e.a_id
WHERE (e.itogo/b.itogo-1)*100 > $NUM
ORDER BY profit DESC;