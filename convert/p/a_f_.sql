-- p.addr, f2m/f2t
COPY (
SELECT id, name->>0 FROM addr WHERE qty = 1 ORDER BY id
) TO STDOUT WITH (FORMAT text);
