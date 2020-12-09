-- m.tx
ALTER TABLE tx ADD CONSTRAINT tx_pkey PRIMARY KEY (id);
ALTER TABLE tx ADD CONSTRAINT tx_b_id_fkey FOREIGN KEY (b_id) REFERENCES bk (id) ON DELETE CASCADE;
CREATE INDEX IF NOT EXISTS idx_tx_b_id ON tx (b_id);
