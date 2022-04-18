SELECT
t_bk.b_id,
t_bk.d,
t_bk.price,
t_bk.total,
t_bk.tx_num,
COALESCE(t_bk_vi.vi_num, 0),
COALESCE(t_bk_vi.vi_num_job, 0),
COALESCE(t_bk_vi.vi_sum, 0),
COALESCE(t_bk_vi.vi_sum_job, 0),
COALESCE(t_bk_vi.vi_max, 0),
t_bk_vo.vo_num,
t_bk_vo.vo_num_job,
t_bk_vo.vo_sum,
t_bk_vo.vo_sum_job,
t_bk_vo.vo_max,
COALESCE(t_bk_so.so_num, 0),
COALESCE(t_bk_so.so_num_job, 0),
COALESCE(t_bk_so.so_sum, 0),
COALESCE(t_bk_so.so_sum_job, 0),
COALESCE(t_bk_so.so_max, 0),
COALESCE(t_bk_lo.lo_num, 0),
COALESCE(t_bk_lo.lo_num_job, 0),
COALESCE(t_bk_lo.lo_sum, 0),
COALESCE(t_bk_lo.lo_sum_job, 0),
COALESCE(t_bk_lo.lo_max, 0),
t_bk_uo.uo_num,
t_bk_uo.uo_num_job,
t_bk_uo.uo_sum,
t_bk_uo.uo_sum_job,
t_bk_uo.uo_max
FROM t_bk
LEFT  JOIN t_bk_vi ON t_bk.b_id = t_bk_vi.b_id
INNER JOIN t_bk_vo ON t_bk.b_id = t_bk_vo.b_id
LEFT  JOIN t_bk_so ON t_bk.b_id = t_bk_so.b_id
LEFT  JOIN t_bk_lo ON t_bk.b_id = t_bk_lo.b_id
INNER JOIN t_bk_uo ON t_bk.b_id = t_bk_uo.b_id
;