-- test_inc_window: Test increment query using window
-- Timing: 0"
-- WARNING: WHERE not works
SELECT
  b_id,
  price,
  total,
  lo_num,
  lo_sum,
  so_num,
  so_sum,
  uo_num,
  uo_sum,
  SUM(price) OVER w AS price_inc,
  SUM(lo_num) OVER w AS lo_num_inc,
  SUM(lo_sum) OVER w AS lo_sum_inc,
  SUM(so_num) OVER w AS so_num_inc,
  SUM(so_sum) OVER w AS so_sum_inc,
  SUM(uo_num) OVER w AS uo_num_inc,
  SUM(uo_sum) OVER w AS uo_sum_inc
FROM t_stat_bk
WINDOW w AS (ORDER BY b_id)
-- default `...  ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW`
ORDER BY b_id
OFFSET 449988  -- WARNING:
LIMIT 20;
