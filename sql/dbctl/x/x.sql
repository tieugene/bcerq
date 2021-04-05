-- txo (table, iss)
INSERT INTO txo (a_id, date0, date1, money)
SELECT
	vout.a_id,
	DATE(bk0.datime) AS date0,
	DATE(tx1.datime) AS date1,
	SUM(money)
FROM vout
INNER JOIN addr ON
	vout.a_id = addr.id
INNER JOIN tx AS tx0 ON
	vout.t_id = tx0.id
INNER JOIN bk AS bk0 ON
	tx0.b_id = bk0.id
LEFT JOIN (
	SELECT
		tx.id AS id,
		bk.datime AS datime
	FROM tx
	INNER JOIN bk ON
	tx.b_id = bk.id
) AS tx1 ON
	vout.t_id_in = tx1.id
WHERE
	money > 0
	AND addr.qty = 1
GROUP BY
  vout.a_id, date0, date1;
