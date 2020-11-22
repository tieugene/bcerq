-- data
ALTER TABLE data ADD CONSTRAINT data_pkey PRIMARY KEY (t_out_id,t_out_n);
ALTER TABLE data ADD CONSTRAINT data_t_out_id_fkey FOREIGN KEY (t_out_id) REFERENCES transactions (t_id) MATCH SIMPLE;
ALTER TABLE data ADD CONSTRAINT data_t_in_id_fkey FOREIGN KEY (t_in_id) REFERENCES transactions (t_id) MATCH SIMPLE;
ALTER TABLE data ADD CONSTRAINT data_a_id_fkey FOREIGN KEY (a_id) REFERENCES addresses (a_id) MATCH SIMPLE;
CREATE INDEX IF NOT EXISTS idx_data_t_in_id ON data (t_in_id);
CREATE INDEX IF NOT EXISTS idx_data_a_id ON data (a_id);
CREATE INDEX IF NOT EXISTS idx_data_satoshi ON data (satoshi);
