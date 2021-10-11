-- Sum of all STXO (raw)
SELECT SUM(money) FROM vout WHERE t_id_in IS NOT NULL;
