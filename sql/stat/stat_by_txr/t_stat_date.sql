CREATE TABLE IF NOT EXISTS t_stat_date (
  d DATE PRIMARY KEY,
  so_num INT NOT NULL,
  so_sum BIGINT NOT NULL,
  lo_num INT NOT NULL,
  lo_sum BIGINT NOT NULL,
  uo_num INT NOT NULL,
  uo_sum BIGINT NOT NULL,
  so_num_inc BIGINT,
  so_sum_inc BIGINT,
  lo_num_inc BIGINT,
  lo_sum_inc BIGINT,
  uo_num_inc BIGINT,
  uo_sum_inc BIGINT
);
