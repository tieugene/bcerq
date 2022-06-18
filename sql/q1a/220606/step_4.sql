-- 1. d0 = '2022-06-01'
-- 2. tx_min
-- SELECT __get_date_tx_min('2022-06-01');
-- 3. r5
-- 4. and get vouts
SELECT
    *
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
    -- 3. limit
    LIMIT 20000
) AS address
INNER JOIN tail ON address.a_id = tail.a_id
WHERE
    (t_id >= 737924083
    OR (t_id_in IS NOT NULL AND t_id_in >= 737924083))
    AND money > 100000
LIMIT 10
;
