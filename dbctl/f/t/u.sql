-- f.tx
ALTER TABLE tx DROP CONSTRAINT IF EXISTS tx_pkey;
ALTER TABLE tx DROP CONSTRAINT IF EXISTS tx_b_id_fkey;
-- ALTER TABLE tx DROP CONSTRAINT IF EXISTS tx_hash_key;