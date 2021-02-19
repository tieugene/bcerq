-- txo
ALTER TABLE vout DROP CONSTRAINT IF EXISTS txo_a_id_fkey;
DROP INDEX IF EXISTS idx_txo_a_id;
DROP INDEX IF EXISTS idx_txo_date0;
DROP INDEX IF EXISTS idx_txo_date1;
DROP INDEX IF EXISTS idx_txo_money;
