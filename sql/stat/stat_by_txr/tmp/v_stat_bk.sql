-- stat_lite_bk: Stat by bk (ext; +sums, job)
DROP TABLE IF EXISTS tmp_stat;
CREATE TEMPORARY TABLE tmp_stat AS
SELECT
    b_id,
    MIN(id) AS tx0,
    MAX(id) AS tx1
FROM tx
WHERE b_id BETWEEN 449990 AND 450010
GROUP BY b_id;
-- main
SELECT
    b_id,
    (SELECT COUNT(*)   FROM tx WHERE tx.b_id = tmp_stat.b_id) AS tx_num,
    (SELECT COUNT(*)   FROM vout WHERE (t_id < tx0) AND (t_id_in BETWEEN tx0 AND tx1)) AS s_num,
    (SELECT SUM(money) FROM vout WHERE (t_id < tx0) AND (t_id_in BETWEEN tx0 AND tx1)) AS s_sum,
    (SELECT COUNT(*)   FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in BETWEEN tx0 AND tx1)) AS l_num,
    (SELECT SUM(money) FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in BETWEEN tx0 AND tx1)) AS l_sum,
    (SELECT COUNT(*)   FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in > tx1 OR t_id_in IS NULL)) AS u_num,
    (SELECT SUM(money) FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in > tx1 OR t_id_in IS NULL)) AS u_sum
FROM tmp_stat;
