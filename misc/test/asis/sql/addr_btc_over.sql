-- {
-- "name": "buratinos_btc_over",
-- "note": "Get addresses with balance over [num] BTC on [todate].",
-- "required": ["DATE1", "NUM"],
-- "header": ["a_id", "address", "profit, ㋛"],
-- "output": "columns name:typ (int,str,Decimal())"
-- }
BEGIN TRANSACTION;
SELECT
    txo.a_id AS a_id,
    addresses.a_list as addr,
    itogo
FROM (
    SELECT a_id, sum(satoshi) as itogo
    from txo_real
    WHERE
        (date0 < '2012-08-31')
        AND (date1 >= '2012-08-31' OR date1 IS NULL)
    GROUP BY a_id
    HAVING SUM(satoshi) >= 1000000000000
) AS txo INNER JOIN addresses ON txo.a_id = addresses.a_id
ORDER BY itogo DESC, a_id ASC;
COMMIT;
