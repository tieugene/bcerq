-- bk_tmp: bk stat table
-- 0. Prepare
CREATE TABLE IF NOT EXISTS t_bk_stat (...);
-- 0.1. views
PREPARE s_bk (int) AS <v_bk.sql>;
PREPARE s_bk_vi (int) AS <v_bk_vi.sql>;
PREPARE s_bk_vo (int) AS <v_bk_vo.sql>;
PREPARE s_bk_so (int) AS <v_bk_so.sql>;
PREPARE s_bk_lo (int) AS <v_bk_lo.sql>;
PREPARE s_bk_uo (int) AS <v_bk_uo.sql>;
-- 1. Fill temps (time for PR)
CREATE TEMP TABLE t_bk    AS EXECUTE s_bk    (450000); -- 450k @ 0:00:11, 250k @  0'04", 450k @  15"
CREATE TEMP TABLE t_bk_vi AS EXECUTE s_bk_vi (450000); -- 450k @ 0:07:46, 250k @ 17'32", 450k @ 24'10"
CREATE TEMP TABLE t_bk_vo AS EXECUTE s_bk_vo (450000); -- 450k @ 1:15:00, 250k @ 18'09", 450k @
CREATE TEMP TABLE t_bk_so AS EXECUTE s_bk_so (450000); -- 450k @ 1:41:34, 250k @ 27'27", 450k @
CREATE TEMP TABLE t_bk_lo AS EXECUTE s_bk_lo (450000); -- 450k @ 1:31:16, 250k @ 27'30", 450k @
CREATE TEMP TABLE t_bk_uo AS EXECUTE s_bk_uo (450000); -- 450k @ 1:43:11, 250k @ 27'15", 450k @
-- idx them
ALTER TABLE t_bk    ADD CONSTRAINT t_bk_pkey    PRIMARY KEY (b_id);
ALTER TABLE t_bk_vi ADD CONSTRAINT t_bk_vi_pkey PRIMARY KEY (b_id);
ALTER TABLE t_bk_vo ADD CONSTRAINT t_bk_vo_pkey PRIMARY KEY (b_id);
ALTER TABLE t_bk_so ADD CONSTRAINT t_bk_so_pkey PRIMARY KEY (b_id);
ALTER TABLE t_bk_lo ADD CONSTRAINT t_bk_lo_pkey PRIMARY KEY (b_id);
ALTER TABLE t_bk_uo ADD CONSTRAINT t_bk_uo_pkey PRIMARY KEY (b_id);
-- 2. Result
TRUNCATE TABLE t_bk_stat;
-- 4"
INSERT INTO t_bk_stat (
  b_id, d, price, total, tx_num,
  vi_num, vi_num_job, vi_sum, vi_sum_job, vi_max,
  vo_num, vo_num_job, vo_sum, vo_sum_job, vo_max,
  so_num, so_num_job, so_sum, so_sum_job, so_max,
  lo_num, lo_num_job, lo_sum, lo_sum_job, lo_max,
  uo_num, uo_num_job, uo_sum, uo_sum_job, uo_max
) (
  <v_bk_stat.sql>
);
-- 3. cleanup
DROP TABLE IF EXISTS t_bk, t_bk_vi, t_bk_vo, t_bk_so, t_bk_lo, t_bk_uo;
