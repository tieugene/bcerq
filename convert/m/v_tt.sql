-- m.vout, t2t
SELECT a_id, date0, COALESCE(date1, '\\N'), money FROM vout ORDER BY date0, date1, a_id;
