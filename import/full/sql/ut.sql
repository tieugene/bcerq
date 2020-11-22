-- transactions
ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_pkey;
ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_hash_key;
ALTER TABLE transactions DROP CONSTRAINT IF EXISTS transactions_b_id_fkey;
DROP INDEX IF EXISTS idx_transactions_b_id;
