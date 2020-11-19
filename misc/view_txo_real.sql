-- txo_real - with addresses only
CREATE VIEW txo_real AS
SELECT
  data.a_id AS a_id,
  DATE(bk0.b_time) AS date0,
  DATE(tx1.b_time) AS date1,
  data.satoshi AS satoshi
FROM data
INNER JOIN transactions AS tx0 ON
  data.t_out_id = tx0.t_id
INNER JOIN blocks AS bk0 ON
  tx0.b_id = bk0.b_id
LEFT JOIN (
  SELECT
    transactions.t_id AS t_id,
    blocks.b_time AS b_time
  FROM transactions
  INNER JOIN blocks ON
  transactions.b_id = blocks.b_id
) AS tx1 ON
  data.t_in_id = tx1.t_id
INNER JOIN addresses ON
  data.a_id = addresses.a_id;
