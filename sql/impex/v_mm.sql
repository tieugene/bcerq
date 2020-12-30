-- p.vout, m2m
COPY (
SELECT t_id, n, money, a_id, t_id_in FROM vout ORDER BY t_id, n
) TO STDOUT WITH (FORMAT text);
