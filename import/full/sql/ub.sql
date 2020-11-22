-- blocks
ALTER TABLE blocks DROP CONSTRAINT IF EXISTS blocks_pkey;
DROP INDEX IF EXISTS idx_blocks_b_time;
