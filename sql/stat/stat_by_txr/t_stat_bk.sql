CREATE TABLE IF NOT EXISTS t_stat_bk (
  b_id INT PRIMARY KEY,
  price BIGINT NOT NULL,
  total BIGINT NOT NULL,
  tx_num SMALLINT NOT NULL,
  so_num INT NOT NULL,
  so_sum BIGINT NOT NULL,
  lo_num INT NOT NULL,
  lo_sum BIGINT NOT NULL,
  uo_num INT NOT NULL,
  uo_sum BIGINT NOT NULL
);
