-- {
-- "name": "alist_abs_btc_chg",
-- "note": "Get balance change (₿) of addresses in [list] in period [fromdate]..[todate].",
-- "required": ["DATE0", "DATE1", "ALIST"],
-- "header": ["a_id", "address", "Start ∑, ₿", "End ∑, ₿", "Profit, ₿"],
-- "output": "columns name:typ (a_id:int,addr:str,satoshi:Decimal())"
-- }
SELECT
    a.a_id AS a_id,
    a.a_list AS addr,
    COALESCE(b.itogo, 0) AS itogo0,
    COALESCE(e.itogo, 0) AS itogo1,
    COALESCE(e.itogo, 0) - COALESCE(b.itogo, 0) AS profit
FROM (
    SELECT a_id, a_list
    FROM addresses
    WHERE a_id IN ($ALIST)
) AS a
LEFT JOIN (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo_real
    WHERE
        (date0 < '$DATE0')
        AND (date1 >= '$DATE0' OR date1 IS NULL)
    GROUP BY a_id
) AS b ON a.a_id = b.a_id
LEFT JOIN (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo_real
    WHERE
        (date0 <= '$DATE1')
        AND (date1 > '$DATE1' OR date1 IS NULL)
    GROUP BY a_id
) AS e ON a.a_id = e.a_id
ORDER BY addr DESC;