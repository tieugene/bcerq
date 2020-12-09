-- m.bk
ALTER TABLE bk ADD CONSTRAINT bk_pkey PRIMARY KEY (id);
CREATE INDEX IF NOT EXISTS idx_bk_datime ON bk (datime);
