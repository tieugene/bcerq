-- f.vout.m
ALTER TABLE vout DROP INDEX IF EXISTS idx_vout_t_id;
ALTER TABLE vout DROP INDEX IF EXISTS idx_vout_t_id_in;
ALTER TABLE vout DROP INDEX IF EXISTS idx_vout_a_id;
ALTER TABLE vout DROP INDEX IF EXISTS idx_vout_money;
