-- R.2: Addr_Num_Active (addrs number active B2n txs); Timing: 50"
DELETE FROM t_1a_date WHERE t_1a_date.d IN (SELECT DISTINCT d FROM tmp_today) AND qid = 2;
WITH const (d) AS (SELECT DISTINCT d FROM tmp_today)
INSERT INTO t_1a_date (d, qid, rid, val)
SELECT
    const.d,
    2,
    tmp_rid.rid,
    COUNT(*) AS val
FROM const, tmp_rid
INNER JOIN (
    WITH const (tx0, tx1) AS (SELECT DISTINCT tx0, tx1 FROM tmp_today)
    SELECT
        DISTINCT a_id
    FROM
        const, tmp_daysnap
    WHERE
        (t_id BETWEEN const.tx0 AND const.tx1)
        OR (t_id_in BETWEEN const.tx0 AND const.tx1)
    ) AS active ON tmp_rid.a_id = active.a_id
GROUP BY const.d, tmp_rid.rid;
