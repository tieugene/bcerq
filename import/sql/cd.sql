-- data
CREATE TABLE IF NOT EXISTS data (
	t_out_id INT NOT NULL REFERENCES transactions(t_id),
	t_out_n INT NOT NULL,
	t_in_id INT REFERENCES transactions(t_id) DEFAULT NULL,
	a_id BIGINT REFERENCES addresses(a_id) DEFAULT NULL,
	satoshi BIGINT NOT NULL,
	PRIMARY KEY (t_out_id, t_out_n)
);
CREATE INDEX IF NOT EXISTS idx_data_t_in_id ON data (t_in_id);
CREATE INDEX IF NOT EXISTS idx_data_a_id ON data (a_id);
CREATE INDEX IF NOT EXISTS idx_data_satoshi ON data (satoshi);
