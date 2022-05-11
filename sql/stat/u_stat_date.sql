-- u_stat_date: Update t_stat_date table
-- Timing: from scratch 220510: 3:12:16
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_stat_date
(
    d DATE PRIMARY KEY,
    tx0 INT,
    tx1 INT
);
TRUNCATE TABLE tmp_stat_date;
INSERT INTO tmp_stat_date (d, tx0, tx1) (
    SELECT
        DATE(datime) AS d,
        MIN(tx.id) AS tx0,
        MAX(tx.id) AS tx1
    FROM tx
    INNER JOIN bk ON tx.b_id = bk.id
    WHERE DATE(datime) BETWEEN
        COALESCE((SELECT MAX(d) FROM t_stat_date), '2009-01-03'::DATE)
        AND (SELECT MAX(DATE(datime)) FROM bk)
    GROUP BY d
);
-- main
-- TRUNCATE TABLE t_stat_date;
DELETE FROM t_stat_date WHERE d = (SELECT MAX(d) FROM t_stat_date);
INSERT INTO t_stat_date (
    d,
    so_num, so_sum, so_j_num, so_j_sum, so_0_num,
    lo_num, lo_sum, lo_j_num, lo_j_sum, lo_0_num,
    uo_num, uo_sum, uo_j_num, uo_j_sum, uo_0_num
) (
    SELECT
        d,
        (SELECT COUNT(*)   FROM vout WHERE (t_id < tx0) AND (t_id_in BETWEEN tx0 AND tx1)) AS s_num,
        COALESCE((SELECT SUM(money) FROM vout WHERE (t_id < tx0) AND (t_id_in BETWEEN tx0 AND tx1)), 0) AS s_sum,
        (SELECT COUNT(*)   FROM vout WHERE (t_id < tx0) AND (t_id_in BETWEEN tx0 AND tx1) AND (money > 0) AND (a_id IS NOT NULL)) AS s_j_num,
        COALESCE((SELECT SUM(money) FROM vout WHERE (t_id < tx0) AND (t_id_in BETWEEN tx0 AND tx1) AND (money > 0) AND (a_id IS NOT NULL)), 0) AS s_j_sum,
        (SELECT COUNT(*)   FROM vout WHERE (t_id < tx0) AND (t_id_in BETWEEN tx0 AND tx1) AND (money = 0)) AS s_0_num,
        (SELECT COUNT(*)   FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in BETWEEN tx0 AND tx1)) AS l_num,
        COALESCE((SELECT SUM(money) FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in BETWEEN tx0 AND tx1)), 0) AS l_sum,
        (SELECT COUNT(*)   FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in BETWEEN tx0 AND tx1) AND (money > 0) AND (a_id IS NOT NULL)) AS l_j_num,
        COALESCE((SELECT SUM(money) FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in BETWEEN tx0 AND tx1) AND (money > 0) AND (a_id IS NOT NULL)), 0) AS l_j_sum,
        (SELECT COUNT(*)   FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in BETWEEN tx0 AND tx1) AND (money = 0)) AS l_0_num,
        (SELECT COUNT(*)   FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in > tx1 OR t_id_in IS NULL)) AS u_num,
        (SELECT SUM(money) FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in > tx1 OR t_id_in IS NULL)) AS u_sum,
        (SELECT COUNT(*)   FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in > tx1 OR t_id_in IS NULL) AND (money > 0) AND (a_id IS NOT NULL)) AS u_j_num,
        COALESCE((SELECT SUM(money) FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in > tx1 OR t_id_in IS NULL) AND (money > 0) AND (a_id IS NOT NULL)), 0) AS u_j_sum,
        (SELECT COUNT(*)   FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in > tx1 OR t_id_in IS NULL) AND (money = 0)) AS u_0_num
    FROM tmp_stat_date
);
DROP TABLE tmp_stat_date;
