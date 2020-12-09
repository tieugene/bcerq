-- m.vout
ALTER TABLE vout ADD CONSTRAINT vout_pkey PRIMARY KEY (t_id,n);
ALTER TABLE vout ADD CONSTRAINT vout_t_id_fkey FOREIGN KEY (t_id) REFERENCES tx (id) ON DELETE CASCADE;
ALTER TABLE vout ADD CONSTRAINT vout_t_id_in_fkey FOREIGN KEY (t_id_in) REFERENCES tx (id) ON DELETE CASCADE;
ALTER TABLE vout ADD CONSTRAINT vout_a_id_fkey FOREIGN KEY (a_id) REFERENCES addr (id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_vout_t_id ON vout (t_id);
CREATE INDEX IF NOT EXISTS idx_vout_t_id_in ON vout (t_id_in);
CREATE INDEX IF NOT EXISTS idx_vout_a_id ON vout (a_id);
CREATE INDEX IF NOT EXISTS idx_vout_money ON vout (money);
