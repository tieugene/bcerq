-- data
ALTER TABLE data DROP CONSTRAINT IF EXISTS data_pkey;
ALTER TABLE data DROP CONSTRAINT IF EXISTS data_t_out_id_fkey;
ALTER TABLE data DROP CONSTRAINT IF EXISTS data_t_in_id_fkey;
ALTER TABLE data DROP CONSTRAINT IF EXISTS data_a_id_fkey;
DROP INDEX IF EXISTS idx_data_t_in_id;
DROP INDEX IF EXISTS idx_data_a_id;
DROP INDEX IF EXISTS idx_data_satoshi;
