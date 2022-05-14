-- u_stat_date_inc: Update date stat incrementals
-- Timing: 0"
UPDATE
    t_stat_date
SET
    so_num_inc = s.so_num_sum,
    so_sum_inc = s.so_sum_sum,
    so_j_num_inc = s.so_j_num_sum,
    so_j_sum_inc = s.so_j_sum_sum,
    so_0_num_inc = s.so_0_num_sum,
    lo_num_inc = s.lo_num_sum,
    lo_sum_inc = s.lo_sum_sum,
    lo_j_num_inc = s.lo_j_num_sum,
    lo_j_sum_inc = s.lo_j_sum_sum,
    lo_0_num_inc = s.lo_0_num_sum,
    uo_num_inc = s.uo_num_sum,
    uo_sum_inc = s.uo_sum_sum,
    uo_j_num_inc = s.uo_j_num_sum,
    uo_j_sum_inc = s.uo_j_sum_sum,
    uo_0_num_inc = s.uo_0_num_sum
FROM (
    SELECT
      d,
      SUM(so_num) OVER w AS so_num_sum,
      SUM(so_sum) OVER w AS so_sum_sum,
      SUM(so_j_num) OVER w AS so_j_num_sum,
      SUM(so_j_sum) OVER w AS so_j_sum_sum,
      SUM(so_0_num) OVER w AS so_0_num_sum,
      SUM(lo_num) OVER w AS lo_num_sum,
      SUM(lo_sum) OVER w AS lo_sum_sum,
      SUM(lo_j_num) OVER w AS lo_j_num_sum,
      SUM(lo_j_sum) OVER w AS lo_j_sum_sum,
      SUM(lo_0_num) OVER w AS lo_0_num_sum,
      SUM(uo_num) OVER w AS uo_num_sum,
      SUM(uo_sum) OVER w AS uo_sum_sum,
      SUM(uo_j_num) OVER w AS uo_j_num_sum,
      SUM(uo_j_sum) OVER w AS uo_j_sum_sum,
      SUM(uo_0_num) OVER w AS uo_0_num_sum
    FROM t_stat_date
    WINDOW w AS (ORDER BY d)
) AS s
WHERE t_stat_date.d = s.d;
