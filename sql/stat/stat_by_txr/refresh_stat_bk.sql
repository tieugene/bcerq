-- refresh_stat_bk: refresh t_stat_bk table
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_stat (
    b_id INT PRIMARY KEY,
    tx0 INT,
    tx1 INT
);
TRUNCATE TABLE tmp_stat;
INSERT INTO tmp_stat (b_id, tx0, tx1) (
    SELECT
        b_id,
        MIN(id) AS tx0,
        MAX(id) AS tx1
    FROM tx
    -- WHERE b_id BETWEEN 449990 AND 450010
    GROUP BY b_id
);
-- main
-- TRUNCATE TABLE t_stat_bk;
-- DELETE FROM t_stat_bk WHERE b_id BETWEEN 449990 AND 450010
INSERT INTO t_stat_bk (
    b_id, price, total, tx_num,
    so_num, so_sum,
    lo_num, lo_sum,
    uo_num, uo_sum
) (
    SELECT
        b_id,
        5000000000>>(b_id/210000) AS price,
        (((1<<((b_id/210000)+1))-2)*210000+(b_id%210000)+1)*(5000000000>>(b_id/210000)) AS total,
        (SELECT COUNT(*)   FROM tx WHERE tx.b_id = tmp_stat.b_id) AS tx_num,
        COALESCE((SELECT COUNT(*)   FROM vout WHERE (t_id < tx0) AND (t_id_in BETWEEN tx0 AND tx1)), 0) AS s_num,
        COALESCE((SELECT SUM(money) FROM vout WHERE (t_id < tx0) AND (t_id_in BETWEEN tx0 AND tx1)), 0) AS s_sum,
        COALESCE((SELECT COUNT(*)   FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in BETWEEN tx0 AND tx1)), 0) AS l_num,
        COALESCE((SELECT SUM(money) FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in BETWEEN tx0 AND tx1)), 0) AS l_sum,
        (SELECT COUNT(*)   FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in > tx1 OR t_id_in IS NULL)) AS u_num,
        (SELECT SUM(money) FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in > tx1 OR t_id_in IS NULL)) AS u_sum
    FROM tmp_stat
);
DROP TABLE tmp_stat;