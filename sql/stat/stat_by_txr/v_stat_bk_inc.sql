-- test_inc_join: Test increment query using self join
-- timing: 1"
SELECT
  m.b_id,
  m.price,
  m.total,
  s.price_inc,
  lo_num,
  s.lo_num_inc
FROM t_stat_bk AS m
INNER JOIN (
    SELECT
      b_id,
      SUM(price) OVER w AS price_inc,
      SUM(lo_num) OVER w AS lo_num_inc,
      SUM(lo_sum) OVER w AS lo_sum_inc,
      SUM(so_num) OVER w AS so_num_inc,
      SUM(so_sum) OVER w AS so_sum_inc,
      SUM(uo_num) OVER w AS uo_num_inc,
      SUM(uo_sum) OVER w AS uo_sum_inc
    FROM t_stat_bk
    WINDOW w AS (ORDER BY b_id)
) AS s ON m.b_id = s.b_id
WHERE m.b_id BETWEEN 449990 AND 450010
ORDER BY b_id;