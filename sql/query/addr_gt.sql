-- {
-- "name": "addr_gt",
-- "note": "     Addresses with balance > [num] ₿ on [todate].",
-- "required": ["DATE1", "NUM"],
-- "header": ["a_id", "address", "balance>N, data"],
-- "output": "columns name:typ (int,str,Decimal())"
-- }
SELECT
    a_id,
    addr.name as address,
    itogo
FROM (
    SELECT a_id, sum(money) as itogo
    FROM txo
    WHERE
        (date0 < '$DATE1')
        AND (date1 >= '$DATE1' OR date1 IS NULL)
    GROUP BY a_id
    HAVING SUM(money) >= $NUM
) AS data INNER JOIN addr ON data.a_id = addr.id
ORDER BY itogo DESC;
