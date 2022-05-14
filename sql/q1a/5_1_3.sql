-- R.3: Utxo_Num (UTXO numbers to the end of the tx); Timing:
DELETE FROM t_1a_date WHERE t_1a_date.d IN (SELECT DISTINCT d FROM tmp_today) AND qid = 3;
WITH const (d, tx1) AS (SELECT DISTINCT d, tx1 FROM tmp_today)
INSERT INTO t_1a_date (d, qid, rid, val)
SELECT
    const.d,
    3,
    tmp_rid.rid,
    COUNT(*) AS num
FROM const, tmp_rid
INNER JOIN tmp_daysnap ON tmp_rid.a_id = tmp_daysnap.a_id
WHERE
    t_id <= const.tx1 AND
    (t_id_in > const.tx1 OR t_id_in IS NULL)
GROUP BY const.d, tmp_rid.rid;
