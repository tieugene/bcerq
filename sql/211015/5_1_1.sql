-- R.1: Addr_Num (addrs number to the end of tx); Timing: 12"
DELETE FROM t_1a_date WHERE t_1a_date.d IN (SELECT DISTINCT d FROM tmp_today) AND qid = 1;
WITH const (d) AS (SELECT DISTINCT d FROM tmp_today)
INSERT INTO t_1a_date (d, qid, rid, val)
SELECT
    const.d,
    1,
    tmp_rid.rid,
    COUNT(*) AS val
FROM const, tmp_rid
GROUP BY const.d, rid;
