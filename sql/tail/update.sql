-- Update tail table; tx0 = 1st tx of new range
-- 0. Prepare
SELECT tx0 BY date - 3 month;
SELECT MAX(t_id FROM tail);
-- 1. Delete unwanted
DELETE FROM tail WHERE tx_id_in < tx0;
-- 2. Update exists
UPDATE tail SET t_id_in = vout.t_id_in FROM vout WHERE
tail.t_id = vout.t_id
AND tail.n = vout.n
AND tail.t_id_in <> vout.t_id_in;
-- 3. Add new
INSERT INTO tail (t_id, n, t_id_in, a_id)
SELECT t_id, n, t_id_in, a_id
FROM vout
WHERE
	t_id > old.t_id
	-- AND a_id IS NOT NULL
	-- AND money > 0
;