-- ctl_utxo: Control request to check UTXOs
-- Timing: 8'43"
DROP TABLE IF EXISTS tmp_today;
CREATE TEMP TABLE tmp_today AS
SELECT DISTINCT
    DATE(datime) AS d,
    MIN(tx.id) AS tx0,
    MAX(tx.id) AS tx1
FROM tx
INNER JOIN bk ON tx.b_id = bk.id
WHERE DATE(datime) = '2022-03-31'
GROUP BY d;
--
WITH const (tx0, tx1) AS (SELECT DISTINCT tx0, tx1 FROM tmp_today)
SELECT
	COUNT(*) AS utxo_num_all,
	SUM(money) AS utxo_sum_all,
	COUNT(*) FILTER (WHERE money > 0 AND a_id IS NOT NULL) AS utxo_num_job,
	SUM(money) FILTER (WHERE money > 0 AND a_id IS NOT NULL) AS utxo_sum_job,
	COUNT(*) FILTER (WHERE money > 0 AND a_id IS NULL) AS utxo_num_ghost,
	SUM(money) FILTER (WHERE money > 0 AND a_id IS NULL) AS utxo_sum_ghost,
	COUNT(*) FILTER (WHERE money = 0) AS utxo_num_0,
	COUNT(*) FILTER (WHERE t_id >= const.tx0) AS vout_num_all,
	SUM(money) FILTER (WHERE t_id >= const.tx0) AS vout_sum_all,
	COUNT(*) FILTER (WHERE t_id >= const.tx0 AND money > 0 AND a_id IS NOT NULL) AS vout_num_job,
	SUM(money) FILTER (WHERE t_id >= const.tx0 AND money > 0 AND a_id IS NOT NULL) AS vout_sum_job,
	COUNT(*) FILTER (WHERE t_id >= const.tx0 AND money > 0 AND a_id IS NULL) AS vout_num_ghost,
	SUM(money) FILTER (WHERE t_id >= const.tx0 AND money > 0 AND a_id IS NULL) AS vout_sum_ghost,
	COUNT(*) FILTER (WHERE t_id >= const.tx0 AND money = 0) AS vout_num_0
FROM const, vout
WHERE
    t_id <= const.tx1
    AND (t_id_in > const.tx1 OR t_id_in IS NULL)
;
