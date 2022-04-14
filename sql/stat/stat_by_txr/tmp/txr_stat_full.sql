-- txr_stat_full: TX range stat (full)
-- bk 450k (tx=190755003..190757158): 4'x"
WITH consts (tx0, tx1) AS (VALUES (190755003, 190757158))
SELECT
    SUM(money) FILTER (WHERE (t_id_in IS NOT NULL) AND (t_id_in < tx0)) AS was_sum,
    COUNT(*) FILTER (WHERE (t_id_in IS NOT NULL) AND (t_id_in < tx0)) AS was_num,
    COUNT(*) FILTER (WHERE (t_id < tx0) AND (t_id_in BETWEEN tx0 AND tx1)) AS so_num,
    COUNT(*) FILTER (WHERE (t_id < tx0) AND (t_id_in > tx1 OR t_id_in IS NULL)) AS ub_num,
    COUNT(*) FILTER (WHERE t_id < tx0) AS allb4_num,
    COUNT(*) FILTER (WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in BETWEEN tx0 AND tx1)) AS lo_num,
    COUNT(*) FILTER (WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in > tx1 OR t_id_in IS NULL)) AS uo_num,
    COUNT(*) FILTER (WHERE t_id BETWEEN tx0 AND tx1) AS vo_num,
    COUNT(*) FILTER (WHERE t_id_in BETWEEN tx0 AND tx1) AS vi_num
FROM vout, consts;
