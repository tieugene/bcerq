-- m.vout, m2m
SELECT t_id, n, money, a_id, COALESCE(t_id_in, '\\N') FROM vout ORDER BY t_id, n;
