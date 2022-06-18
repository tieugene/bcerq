-- 1. d0 = '2022-06-01'
-- 2. tx_min
-- SELECT __get_date_tx_min('2022-06-01');
-- 3. r5
-- 4. and get vouts
-- 5. and with dates and addrs
SELECT
    lave.a_id AS a_id,
    addr.name AS a_name,
    lave.money AS money,
    bk1.datime AS dt0,
    bk2.datime AS dt1
FROM (
    SELECT
        address.a_id,
        tail.t_id AS t_id,
        tail.t_id_in AS t_id_in,
        tail.money AS money
    FROM (
        SELECT
            b5.a_id AS a_id
        FROM (
            -- 1. all rid
            SELECT
                a_id
            FROM
                tail
            WHERE
                t_id < 737924083
                AND (t_id_in IS NULL OR t_id_in >= 737924083)
                AND a_id IS NOT NULL
                AND money > 0
            GROUP BY a_id
            HAVING SUM(money) BETWEEN 1 + 10 ^ 8 AND 10 ^ 9
        ) AS b5
        INNER JOIN (
            -- 2. count >= 2
            SELECT
                a_id
            FROM
                tail
            WHERE
                (t_id >= 737924083
                OR (t_id_in IS NOT NULL AND t_id_in >= 737924083))
                AND money > 100000
            GROUP BY a_id
            HAVING
                COUNT(*) >= 2
        ) AS active
        ON b5.a_id = active.a_id
        -- 3. limit, addrs
        LIMIT 200000
    ) AS address
    INNER JOIN tail ON address.a_id = tail.a_id
    WHERE
        (t_id >= 737924083
        OR (t_id_in IS NOT NULL AND t_id_in >= 737924083))
        AND money > 100000
) AS lave
INNER JOIN addr ON addr.id = lave.a_id
INNER JOIN tx AS tx1 ON tx1.id = lave.t_id
INNER JOIN bk AS bk1 ON tx1.b_id = bk1.id
LEFT JOIN tx AS tx2 ON tx2.id = lave.t_id_in
LEFT JOIN bk AS bk2 ON tx2.b_id = bk2.id
ORDER BY lave.a_id, dt0, dt1
;
-- ----: 342476
-- II--: 342476
-- IILL: 342476
-- IIII: 265335
-- IILI: 265335
