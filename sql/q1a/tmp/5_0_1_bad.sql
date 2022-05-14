-- Fill daily snapshot (bad way, 26')
DROP TABLE IF EXISTS tmp_daysnap;
-- CREATE TEMP TABLE tmp_daysnap AS TABLE vout WITH NO DATA;
CREATE TEMP TABLE tmp_daysnap (LIKE vout INCLUDING ALL);
WITH const (d, tx0, tx1) AS (VALUES ('2022-03-31', 721765790, 722043870))
INSERT INTO tmp_daysnap
    SELECT tail.*
    FROM tail, const
    WHERE t_id <= const.tx1 AND (t_id_in > const.tx0 OR t_id_in IS NULL);
