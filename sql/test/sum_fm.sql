-- sum of all TXO (vout, by vin)
SELECT SUM(money) FROM vout WHERE t_id_in IS NOT NULL;
