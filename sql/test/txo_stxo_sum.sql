-- Sum of all STXO (txo)
SELECT SUM(money) FROM txo WHERE date1 IS NOT NULL;
