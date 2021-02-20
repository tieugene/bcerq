-- {
-- "name": "addr_gt",
-- "note": "     Addresses with balance > [num] ₿ on [todate].",
-- "required": ["DATE1", "NUM"],
-- "header": ["a_id", "address", "balance>N, data"],
-- "output": "columns name:typ (int,str,Decimal())"
-- }
SELECT
    txo.a_id AS a_id,
    addresses.a_list as addr,
    itogo
FROM (
    SELECT a_id, sum(satoshi) as itogo
    FROM txo
    WHERE
        (date0 < '$DATE1')
        AND (date1 >= '$DATE1' OR date1 IS NULL)
    GROUP BY a_id
    HAVING SUM(satoshi) >= $NUM
) AS txo INNER JOIN addresses ON txo.a_id = addresses.a_id
ORDER BY itogo DESC;
