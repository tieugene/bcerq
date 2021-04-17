-- Sum of all UTXO (raw)
SELECT SUM(money) FROM vout WHERE t_id_in IS NULL;
