-- 5_0_1: Fill daily snapshot
-- Note: change 'tail' to 'vout'
-- Timing (2022-03-31): 20' (vout) / 4'20" (tail); 80969927 records
-- Count: 132038344 (all) = 80969927 + 296027/10648.46354633 BTC (aid is null & money > 0) + 50772390 (money = 0)
DROP TABLE IF EXISTS tmp_daysnap;
WITH const (tx0, tx1) AS (SELECT DISTINCT tx0, tx1 FROM tmp_today)
SELECT tail.*
    INTO TEMP TABLE tmp_daysnap
    FROM const, tail
    WHERE
        t_id <= const.tx1
        AND (t_id_in > const.tx0 OR t_id_in IS NULL)
        AND a_id IS NOT NULL
        AND money > 0
;
CREATE INDEX tmp_daysnap_t_id_idx ON tmp_daysnap (t_id);
CREATE INDEX tmp_daysnap_t_id_in_idx ON tmp_daysnap (t_id_in);
CREATE INDEX tmp_daysnap_a_id_idx ON tmp_daysnap (a_id);
CREATE INDEX tmp_daysnap_money_idx ON tmp_daysnap (money);
ALTER TABLE tmp_daysnap ADD CONSTRAINT tmp_daysnap_pkey PRIMARY KEY (t_id,n);
