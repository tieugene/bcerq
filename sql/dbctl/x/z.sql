-- txo (view)
CREATE VIEW txo AS
SELECT
  vout.a_id AS a_id,
  DATE(bk0.datime) AS date0,
  DATE(tx1.datime) AS date1,
  vout.money AS money
FROM vout
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
  vout.t_id_in = tx1.id;
