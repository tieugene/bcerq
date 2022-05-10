-- u_stat_bk: Update t_stat_bk table
-- 1. prepare
CREATE OR REPLACE PROCEDURE test_tops() AS $$
    -- bk == stat => QUIT (including NULL)
    BEGIN
        IF (SELECT MAX(id) FROM bk) = (SELECT MAX(b_id) FROM t_stat_bk) THEN
            RAISE EXCEPTION 'No update reuired';
        END IF;
    END
$$ LANGUAGE plpgsql;
CALL test_tops();
CREATE TEMPORARY TABLE IF NOT EXISTS tmp_stat_bk (
    b_id INT PRIMARY KEY,
    tx0 INT,
    tx1 INT
);
TRUNCATE TABLE tmp_stat_bk;
INSERT INTO tmp_stat_bk (b_id, tx0, tx1) (
    SELECT
        b_id,
        MIN(id) AS tx0,
        MAX(id) AS tx1
    FROM tx
    WHERE b_id BETWEEN  -- from 0 if stat is empty
        (SELECT COALESCE(MAX(b_id)+1, 0) FROM t_stat_bk)
        AND (SELECT MAX(id) FROM bk)
    GROUP BY b_id
);
-- 2. main
-- TRUNCATE TABLE t_stat_bk;
-- DELETE FROM t_stat_bk WHERE b_id BETWEEN 449990 AND 450010;⇒
INSERT INTO t_stat_bk (
    b_id, tx_num,
    so_num, so_sum, so_j_num, so_j_sum, so_0_num,
    lo_num, lo_sum, lo_j_num, lo_j_sum, lo_0_num,
    uo_num, uo_sum, uo_j_num, uo_j_sum, uo_0_num
) (
    SELECT
        b_id,
        (SELECT COUNT(*)   FROM tx WHERE tx.b_id = tmp_stat_bk.b_id) AS tx_num,
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
    FROM tmp_stat_bk
);
DROP TABLE tmp_stat_bk;
