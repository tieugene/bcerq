-- {
-- "name": "addr_cnt_min",
-- "note": "Top [num] addresses by lost (%) in period [fromdate]..[todate].",
-- "required": ["DATE0", "DATE1", "NUM"],
-- "header": ["a_id", "address", "∑₀, ㋛", "∑₁, ㋛", "loss, %"],
-- "output": "columns name:typ"
-- }
SELECT
    b.a_id AS a_id,
    addresses.a_list AS addr,
    b.itogo AS itogo0,
    e.itogo AS itogo1,
    ROUND((1-b.itogo/e.itogo)*100, 0) AS profit
FROM (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo
    WHERE
        (date0 < '$DATE0')
        AND (date1 >= '$DATE0' OR date1 IS NULL)
    GROUP BY a_id
) AS b INNER JOIN (
    SELECT a_id, SUM(satoshi) AS itogo
    FROM txo
    WHERE
        (date0 <= '$DATE1')
        AND (date1 > '$DATE1' OR date1 IS NULL)
    GROUP BY a_id
    HAVING SUM(satoshi) > 0
) AS e ON b.a_id = e.a_id
INNER JOIN addresses ON e.a_id = addresses.a_id
ORDER BY profit ASC
LIMIT $NUM;