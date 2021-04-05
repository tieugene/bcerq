-- tables
\dt
-- indexes
SELECT tablename, indexname FROM pg_indexes WHERE schemaname = 'public' ORDER BY tablename, indexname;
-- constraints
SELECT
	ccu.table_name AS tablename,
	pgc.conname AS constraint_name
FROM pg_constraint pgc
JOIN pg_namespace nsp ON nsp.oid = pgc.connamespace
JOIN pg_class cls ON pgc.conrelid = cls.oid
LEFT JOIN information_schema.constraint_column_usage ccu
          ON pgc.conname = ccu.constraint_name
          AND nsp.nspname = ccu.constraint_schema
WHERE ccu.table_schema = 'public'
ORDER BY ccu.table_name, pgc.conname;
-- views
