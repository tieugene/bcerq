-- t.addr
ALTER TABLE addr ADD CONSTRAINT addr_pkey PRIMARY KEY (id);
ALTER TABLE addr ADD CONSTRAINT addr_name_key UNIQUE (name);
