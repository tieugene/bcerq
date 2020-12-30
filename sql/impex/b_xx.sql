-- p.bk, f2f/m2m
COPY (
SELECT id, datime FROM bk ORDER BY id
) TO STDOUT WITH (FORMAT text);
