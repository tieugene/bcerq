-- p.tx, f2m/m2m
COPY (
SELECT id, b_id FROM tx ORDER BY id
) TO STDOUT WITH (FORMAT text);
