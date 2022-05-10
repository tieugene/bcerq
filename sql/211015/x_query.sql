-- Pivot table
-- CREATE EXTENSION IF NOT EXISTS tablefunc;
SELECT * FROM crosstab(
    $$ SELECT d, rid, val FROM t_1a_date WHERE qid=1 ORDER BY d, rid; $$
    -- , $$ SELECT * FROM (VALUES ('≤.001'), ('≤.01'), ('≤.1'), ('≤1'), ('≤10'), ('≤100'), ('≤1k'), ('≤10k'), ('≤100k'), ('≤1m'), ('>1m')) AS t; $$
) AS (d DATE, rid1 BIGINT, rid2 BIGINT, rid3 BIGINT, rid4 BIGINT, rid5 BIGINT, rid6 BIGINT, rid7 BIGINT, rid8 BIGINT, rid9 BIGINT, rid10 BIGINT)
ORDER BY d;
