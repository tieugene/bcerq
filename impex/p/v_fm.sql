-- p.vout, f2m
COPY (
SELECT
	t_id, n, money, a_id, t_id_in
FROM vout
INNER JOIN addr ON
	vout.a_id = addr.id
WHERE
	money > 0
	AND addr.qty = 1
ORDER BY
	t_id, n
) TO STDOUT WITH (FORMAT text);
