-- p.bk, f2m
COPY (
SELECT id, DATE(datime) FROM bk ORDER BY id
) TO STDOUT WITH (FORMAT text);
