-- Sum of all UTXO (txo)
SELECT SUM(money) FROM txo WHERE date1 IS NULL;
