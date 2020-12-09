-- t.vout.m
ALTER TABLE vout DROP INDEX IF EXISTS idx_vout_a_id;
ALTER TABLE vout DROP INDEX IF EXISTS idx_vout_date0;
ALTER TABLE vout DROP INDEX IF EXISTS idx_vout_date1;
ALTER TABLE vout DROP INDEX IF EXISTS idx_vout_money;
