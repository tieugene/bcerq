-- trasactions
ALTER TABLE transactions ADD CONSTRAINT transactions_pkey PRIMARY KEY (t_id);
ALTER TABLE transactions ADD CONSTRAINT transactions_hash_key UNIQUE (hash);
ALTER TABLE transactions ADD CONSTRAINT transactions_b_id_fkey FOREIGN KEY (b_id) REFERENCES blocks (b_id) MATCH SIMPLE;
CREATE INDEX IF NOT EXISTS idx_transactions_b_id ON transactions (b_id);
