-- addresses
ALTER TABLE addresses ADD CONSTRAINT addresses_pkey PRIMARY KEY (a_id);
ALTER TABLE addresses ADD CONSTRAINT addresses_a_list_key UNIQUE (a_list);
CREATE INDEX IF NOT EXISTS idx_addresses_n ON addresses (n);
