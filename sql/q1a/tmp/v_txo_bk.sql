CREATE VIEW v_txo_bk AS
SELECT
  vout.money AS money,
  tx0.b_id AS bk0,
  tx1.b_id AS bk1,
  vout.a_id AS a_id
FROM vout
INNER JOIN tx AS tx0 ON
  vout.t_id = tx0.id
LEFT JOIN tx AS tx1 ON
  vout.t_id_in = tx1.id;