-- date_tx: list of date tx
SELECT
    DATE(datime) AS d,
    MIN(tx.id) AS tx0,
    MAX(tx.id) AS tx1
FROM tx
INNER JOIN bk ON tx.b_id = bk.id
GROUP BY d;
