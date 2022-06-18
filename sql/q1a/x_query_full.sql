-- Pivot table
-- CREATE EXTENSION IF NOT EXISTS tablefunc;
CREATE OR REPLACE PROCEDURE _q1a_x(q SMALLINT, d0 DATE, d1 DATE)
    LANGUAGE sql
AS
$$
CREATE TEMP TABLE IF NOT EXISTS tmp_snap (LIKE vout INCLUDING ALL);
$$;
COMMENT ON PROCEDURE _q1a_x() IS 'Pivot table for q1a.
@ver: 22020514.16.30';

SELECT
    x.d AS d,
    COALESCE(rid1, 0) AS rid1,
    COALESCE(rid2, 0) AS rid1,
    COALESCE(rid3, 0) AS rid2,
    COALESCE(rid4, 0) AS rid3,
    COALESCE(rid5, 0) AS rid4,
    COALESCE(rid6, 0) AS rid5,
    COALESCE(rid7, 0) AS rid6,
    COALESCE(rid7, 0) AS rid7,
    COALESCE(rid8, 0) AS rid8,
    COALESCE(rid9, 0) AS rid9,
    COALESCE(rid10, 0) AS rid10,
    COALESCE(rid11, 0) AS rid11,
    t.total AS total
FROM crosstab(
    $$ SELECT d, rid, val FROM t_1a_date WHERE qid=1 ORDER BY d, rid; $$
) AS x (d DATE, rid1 BIGINT, rid2 BIGINT, rid3 BIGINT, rid4 BIGINT, rid5 BIGINT, rid6 BIGINT, rid7 BIGINT, rid8 BIGINT, rid9 BIGINT, rid10 BIGINT, rid11 BIGINT)
INNER JOIN (
    SELECT d, SUM(val) AS total FROM t_1a_date WHERE qid=1 GROUP BY d
) AS t ON x.d = t.d
WHERE x.d BETWEEN '2022-03-01' AND '2022-03-31'
ORDER BY d;