-- p.addr, f2f
COPY (
SELECT id, name, qty FROM addr ORDER BY id
) TO STDOUT WITH (FORMAT text);
