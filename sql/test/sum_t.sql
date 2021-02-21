-- sum of all TXO
SELECT SUM(money) FROM txo WHERE date1 IS NOT NULL;