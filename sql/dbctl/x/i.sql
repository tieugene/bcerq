-- txo.i
CREATE INDEX IF NOT EXISTS idx_txo_a_id ON txo (a_id);
CREATE INDEX IF NOT EXISTS idx_txo_date0 ON txo (date0);
CREATE INDEX IF NOT EXISTS idx_txo_date1 ON txo (date1);
CREATE INDEX IF NOT EXISTS idx_txo_money ON txo (money);
ALTER TABLE txo ADD CONSTRAINT txo_a_id_fkey FOREIGN KEY (a_id) REFERENCES addr (id) ON DELETE CASCADE;
