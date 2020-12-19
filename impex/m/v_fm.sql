-- m.vout, f2m
SELECT
	t_id, n, money, a_id, COALESCE(t_id_in, '\\N')
FROM vout
INNER JOIN addr ON
	vout.a_id = addr.id
WHERE
	money > 0
	AND addr.qty = 1
ORDER BY
	t_id, n;
