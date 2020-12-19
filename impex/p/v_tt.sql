-- p.vout, m2m
COPY (
SELECT a_id, date0, date1, money FROM vout ORDER BY date0, date1, a_id
) TO STDOUT WITH (FORMAT text);
