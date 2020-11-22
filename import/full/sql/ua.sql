-- addresses
ALTER TABLE addresses DROP CONSTRAINT IF EXISTS addresses_pkey;
ALTER TABLE addresses DROP CONSTRAINT IF EXISTS addresses_a_list_key;
DROP INDEX IF EXISTS idx_addresses_n;
