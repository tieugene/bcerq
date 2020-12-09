-- t.vout
-- ALTER TABLE vout ADD CONSTRAINT data_pkey PRIMARY KEY (a_id, date0, date1);
ALTER TABLE vout ADD CONSTRAINT vout_a_id_fkey FOREIGN KEY (a_id) REFERENCES addr (id) ON DELETE CASCADE;
ALTER TABLE vout ADD CONSTRAINT vout_money_check CHECK (money > 0);
CREATE INDEX IF NOT EXISTS idx_vout_a_id ON vout (a_id);
CREATE INDEX IF NOT EXISTS idx_vout_date0 ON vout (date0);
CREATE INDEX IF NOT EXISTS idx_vout_date1 ON vout (date1);
CREATE INDEX IF NOT EXISTS idx_vout_money ON vout (money);
