-- sum of all TXO (txo, by date1)
SELECT SUM(money) FROM txo WHERE date1 IS NOT NULL;
