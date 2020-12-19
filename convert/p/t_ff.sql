-- p.tx, f2f
COPY (
SELECT id, b_id, hash FROM tx ORDER BY id
) TO STDOUT WITH (FORMAT text);
