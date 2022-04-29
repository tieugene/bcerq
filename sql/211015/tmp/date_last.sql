-- Остатки на конец дня
WITH consts (d, tx0, tx1) AS (VALUES ('2022-03-31', 721765790, 722043870))
SELECT
    COUNT(*),
    SUM(money)
FROM
    vout, consts
WHERE
    -- Остатки на конец дня
    -- t_id <= consts.tx1 AND (t_id_in > consts.tx1 OR t_id_in IS NULL)
    -- Обороты за день
    -- (t_id BETWEEN consts.tx0 AND consts.tx1) OR (t_id_in BETWEEN consts.tx0 AND consts.tx1)
    -- Остатки на конец дня + Обороты за день
    t_id <= consts.tx1 AND (t_id_in > consts.tx0 OR t_id_in IS NULL) AND a_id IS NOT NULL AND money > 0;
;
