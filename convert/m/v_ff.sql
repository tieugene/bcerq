-- m.vout, f2f
SELECT t_id, n, money, COALESCE(a_id, '\\N'), COALESCE(t_id_in, '\\N') FROM vout ORDER BY t_id, n;
