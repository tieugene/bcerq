-- txr_stat_lite: TX range stat (lite)
WITH consts (tx0, tx1) AS (VALUES (190755003, 190757158))
SELECT
    COUNT(*) FILTER (WHERE (t_id BETWEEN tx0 AND tx1) AND (t_id_in BETWEEN tx0 AND tx1)) AS lo_num,
    COUNT(*) FILTER (WHERE t_id BETWEEN tx0 AND tx1) AS vo_num,
    COUNT(*) FILTER (WHERE t_id_in BETWEEN tx0 AND tx1) AS vi_num
FROM vout, consts
WHERE (t_id BETWEEN tx0 AND tx1) OR (t_id_in BETWEEN tx0 AND tx1)
;