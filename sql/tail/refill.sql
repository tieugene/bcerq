-- tail.fill: fill out the table from scratch

CREATE OR REPLACE PROCEDURE __tbl_i_tail()
    LANGUAGE sql
AS
$$
    CREATE INDEX IF NOT EXISTS tail_t_id_idx ON tail (t_id);
    CREATE INDEX IF NOT EXISTS tail_t_id_in_idx ON tail (t_id_in);
    CREATE INDEX IF NOT EXISTS tail_a_id_idx ON tail (a_id);
    CREATE INDEX IF NOT EXISTS tail_money_idx ON tail (money);
    ALTER TABLE tail
        ADD CONSTRAINT tail_pkey PRIMARY KEY (t_id, n);
    ALTER TABLE tail
        ADD CONSTRAINT tail_t_id_fkey FOREIGN KEY (t_id) REFERENCES tx (id) ON DELETE CASCADE;
    ALTER TABLE tail
        ADD CONSTRAINT tail_t_id_in_fkey FOREIGN KEY (t_id_in) REFERENCES tx (id) ON DELETE CASCADE;
    ALTER TABLE tail
        ADD CONSTRAINT tail_a_id_fkey FOREIGN KEY (a_id) REFERENCES addr (id) ON DELETE CASCADE;
    $$;
COMMENT ON PROCEDURE __tbl_i_tail() IS 'Indexing tail table.
@ver: 220514.12';

CREATE OR REPLACE PROCEDURE __tbl_u_tail()
    LANGUAGE sql
AS
$$
DROP INDEX IF EXISTS tail_t_id_idx;
DROP INDEX IF EXISTS tail_t_id_in_idx;
DROP INDEX IF EXISTS tail_a_id_idx;
DROP INDEX IF EXISTS tail_money_idx;
    ALTER TABLE tail
        DROP CONSTRAINT IF EXISTS tail_pkey;
    ALTER TABLE tail
        DROP CONSTRAINT IF EXISTS tail_t_id_fkey;
    ALTER TABLE tail
        DROP CONSTRAINT IF EXISTS tail_t_id_in_fkey;
    ALTER TABLE tail
        DROP CONSTRAINT IF EXISTS tail_a_id_fkey;
    $$;
COMMENT ON PROCEDURE __tbl_u_tail() IS 'UnIndexing tail table.
@ver: 220514.12';

CREATE OR REPLACE PROCEDURE __tail_fill(tx0 INTEGER)
    LANGUAGE sql
AS
$$
INSERT INTO tail
SELECT *
FROM vout
WHERE (t_id >= tx0 OR t_id_in >= tx0 OR t_id_in IS NULL)
  AND a_id IS NOT NULL
  AND money > 0;
$$;
COMMENT ON PROCEDURE __tail_fill() IS 'Fill tail table.
@ver: 220514.12';

CREATE OR REPLACE PROCEDURE _tail_refill(d DATE)
    LANGUAGE sql
AS
$$
    -- 26'
    TRUNCATE TABLE tail;  -- 0"
    CALL __tbl_u_tail();  -- 0"
    CALL __tail_fill(__get_date_tx_min(d));  -- 7'40"+
    CALL __tbl_i_tail();  -- 10'20"+
$$;
COMMENT ON PROCEDURE __tail_fill() IS 'ReFill tail table.
@ver: 220514.12';

-- Usage: _tail_refill('2022-01-03');
