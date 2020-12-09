-- addr
ALTER TABLE addr ADD CONSTRAINT addr_pkey PRIMARY KEY (id);
-- ALTER TABLE addr ADD CONSTRAINT addr_name_key UNIQUE (name);
CREATE INDEX IF NOT EXISTS idx_addr_qty ON addr (qty);
