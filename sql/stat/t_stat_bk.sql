CREATE TABLE IF NOT EXISTS t_stat_bk (
  b_id INT PRIMARY KEY,
  tx_num SMALLINT NOT NULL,
  so_num INT NOT NULL,
  so_sum BIGINT NOT NULL,
  lo_num INT NOT NULL,
  lo_sum BIGINT NOT NULL,
  uo_num INT NOT NULL,
  uo_sum BIGINT NOT NULL,
  tx_num_inc BIGINT,
  so_num_inc BIGINT,
  so_sum_inc BIGINT,
  lo_num_inc BIGINT,
  lo_sum_inc BIGINT,
  uo_num_inc BIGINT,
  uo_sum_inc BIGINT
);
ALTER TABLE t_stat_bk ADD CONSTRAINT t_stat_bk_b_id_fkey FOREIGN KEY (b_id) REFERENCES bk (id) ON DELETE CASCADE;
