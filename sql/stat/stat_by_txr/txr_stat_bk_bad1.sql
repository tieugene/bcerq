-- too long
SELECT
    COUNT(*) FILTER (WHERE (tx_o.b_id = 450000) AND (tx_i.b_id = 450000)) AS lo_num
FROM vout
INNER JOIN tx AS tx_o ON vout.t_id = tx_o.id
INNER JOIN tx AS tx_i ON vout.t_id_in = tx_i.id
WHERE tx_o.b_id = 450000 OR tx_i.b_id = 450000;