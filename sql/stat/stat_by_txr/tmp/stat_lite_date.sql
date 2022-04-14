-- stat_lite_bk: Stat by date (lite)
DROP TABLE IF EXISTS tmp_date;
CREATE TEMPORARY TABLE tmp_date AS
SELECT
    DATE(datime) AS d,
    MIN(tx.id) AS tx0,
    MAX(tx.id) AS tx1
FROM tx
INNER JOIN bk ON tx.b_id = bk.id
WHERE DATE(datime) BETWEEN '2021-12-01' AND '2021-12-31'
GROUP BY d;
SELECT
    d,
    -- tx0,
    -- tx1,
    (SELECT COUNT(*) FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in BETWEEN tx0 AND tx1)) AS l_num,
    (SELECT COUNT(*) FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in > tx1 OR t_id_in IS NULL)) AS u_num,
    (SELECT COUNT(*) FROM vout WHERE (t_id < tx0) AND (t_id_in BETWEEN tx0 AND tx1)) AS s_num
FROM tmp_date;
