-- refresh_stat_date: refresh t_stat_date table
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_stat
(
    d DATE PRIMARY KEY,
    tx0 INT,
    tx1 INT
);
TRUNCATE TABLE tmp_stat;
INSERT INTO tmp_stat (d, tx0, tx1) (
    SELECT
        DATE(datime) AS d,
        MIN(tx.id) AS tx0,
        MAX(tx.id) AS tx1
    FROM tx
    INNER JOIN bk ON tx.b_id = bk.id
    -- WHERE DATE(datime) BETWEEN '2021-12-01' AND '2021-12-31'
    GROUP BY d
);
-- main
-- TRUNCATE TABLE t_stat_date;
-- DELETE FROM t_stat_date WHERE d '2021-12-01' AND '2021-12-31';
INSERT INTO t_stat_date (
    d,
    so_num, so_sum,
    lo_num, lo_sum,
    uo_num, uo_sum
) (
    SELECT
        d,
        COALESCE((SELECT COUNT(*)   FROM vout WHERE (t_id < tx0) AND (t_id_in BETWEEN tx0 AND tx1)), 0) AS s_num,
        COALESCE((SELECT SUM(money) FROM vout WHERE (t_id < tx0) AND (t_id_in BETWEEN tx0 AND tx1)), 0) AS s_sum,
        COALESCE((SELECT COUNT(*)   FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in BETWEEN tx0 AND tx1)), 0) AS l_num,
        COALESCE((SELECT SUM(money) FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in BETWEEN tx0 AND tx1)), 0) AS l_sum,
        (SELECT COUNT(*)   FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in > tx1 OR t_id_in IS NULL)) AS u_num,
        (SELECT SUM(money) FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in > tx1 OR t_id_in IS NULL)) AS u_sum
    FROM tmp_stat
);
DROP TABLE tmp_stat;
