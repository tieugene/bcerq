-- stat_lite_bk: Stat by bk (lite)
DROP TABLE IF EXISTS tmp_bk;
CREATE TEMPORARY TABLE tmp_bk AS
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
    -- tx0,
    -- tx1,
    (SELECT COUNT(*) FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in BETWEEN tx0 AND tx1)) AS l_num,
    (SELECT COUNT(*) FROM vout WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in > tx1 OR t_id_in IS NULL)) AS u_num,
    (SELECT COUNT(*) FROM vout WHERE (t_id < tx0) AND (t_id_in BETWEEN tx0 AND tx1)) AS s_num
FROM tmp_bk;
