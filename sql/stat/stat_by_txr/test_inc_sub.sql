-- test_inc_join: Test increment query using subqueries
-- timing: 20"
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
  (SELECT SUM(price) FROM t_stat_bk AS s WHERE s.b_id < m.b_id) AS price_inc,
  (SELECT SUM(lo_num) FROM t_stat_bk AS s WHERE s.b_id < m.b_id) AS lo_num_inc,
  (SELECT SUM(lo_sum) FROM t_stat_bk AS s WHERE s.b_id < m.b_id) AS lo_sum_inc,
  (SELECT SUM(so_num) FROM t_stat_bk AS s WHERE s.b_id < m.b_id) AS so_num_inc,
  (SELECT SUM(so_sum) FROM t_stat_bk AS s WHERE s.b_id < m.b_id) AS so_sum_inc,
  (SELECT SUM(uo_num) FROM t_stat_bk AS s WHERE s.b_id < m.b_id) AS uo_num_inc,
  (SELECT SUM(uo_sum) FROM t_stat_bk AS s WHERE s.b_id < m.b_id) AS uo_sum_inc
FROM t_stat_bk AS m
WHERE b_id BETWEEN 449990 AND 450010
ORDER BY b_id;