-- p.addr, m2m/m2t
COPY (
SELECT id, name FROM addr ORDER BY id
) TO STDOUT WITH (FORMAT text);
