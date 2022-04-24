-- tail.i: indexing
-- timing: 13'37" for 2022-01-01..2022-04-20
CREATE INDEX IF NOT EXISTS tail_t_id_idx ON tail (t_id);
CREATE INDEX IF NOT EXISTS tail_t_id_in_idx ON tail (t_id_in);
CREATE INDEX IF NOT EXISTS tail_a_id_idx ON tail (a_id);
CREATE INDEX IF NOT EXISTS tail_money_idx ON tail (money);
ALTER TABLE tail ADD CONSTRAINT tail_pkey PRIMARY KEY (t_id,n);
ALTER TABLE tail ADD CONSTRAINT tail_t_id_fkey FOREIGN KEY (t_id) REFERENCES tx (id) ON DELETE CASCADE;
ALTER TABLE tail ADD CONSTRAINT tail_t_id_in_fkey FOREIGN KEY (t_id_in) REFERENCES tx (id) ON DELETE CASCADE;
ALTER TABLE tail ADD CONSTRAINT tail_a_id_fkey FOREIGN KEY (a_id) REFERENCES addr (id) ON DELETE CASCADE;
