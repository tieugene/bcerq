-- f.addr.p
ALTER TABLE addr DROP CONSTRAINT IF EXISTS addr_pkey;
DROP INDEX IF EXISTS idx_addr_qty;
