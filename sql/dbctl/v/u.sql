-- vout.u
ALTER TABLE vout DROP CONSTRAINT IF EXISTS vout_t_id_fkey;
ALTER TABLE vout DROP CONSTRAINT IF EXISTS vout_t_id_in_fkey;
ALTER TABLE vout DROP CONSTRAINT IF EXISTS vout_a_id_fkey;
ALTER TABLE vout DROP CONSTRAINT IF EXISTS vout_pkey;
DROP INDEX IF EXISTS idx_vout_t_id;
DROP INDEX IF EXISTS idx_vout_t_id_in;
DROP INDEX IF EXISTS idx_vout_a_id;
DROP INDEX IF EXISTS idx_vout_money;
