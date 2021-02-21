-- sum of all TXO
SELECT SUM(money) FROM vout WHERE t_id_in IS NOT NULL;