-- beg_tx: Find starting tx.id of the tail
SELECT MIN(tx.id) FROM tx INNER JOIN bk ON tx.b_id = bk.id WHERE DATE(datime) = '2022-01-01';
