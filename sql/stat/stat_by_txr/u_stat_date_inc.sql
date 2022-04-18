-- u_stat_date: Update date stat incrementals
-- Timing: 0"
UPDATE
    t_stat_date
SET
    so_num_inc = s.so_num_sum,
    so_sum_inc = s.so_sum_sum,
    lo_num_inc = s.lo_num_sum,
    lo_sum_inc = s.lo_sum_sum,
    uo_num_inc = s.uo_num_sum,
    uo_sum_inc = s.uo_sum_sum
FROM (
    SELECT
      d,
      SUM(so_num) OVER w AS so_num_sum,
      SUM(so_sum) OVER w AS so_sum_sum,
      SUM(lo_num) OVER w AS lo_num_sum,
      SUM(lo_sum) OVER w AS lo_sum_sum,
      SUM(uo_num) OVER w AS uo_num_sum,
      SUM(uo_sum) OVER w AS uo_sum_sum
    FROM t_stat_date
    WINDOW w AS (ORDER BY d)
) AS s
WHERE t_stat_date.d = s.d;
