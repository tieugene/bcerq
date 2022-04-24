-- tail.fill: fill out the table from scratch
-- timing: 8'34" for 2022-01-01..2022-04-20
INSERT INTO tail SELECT * FROM vout WHERE t_id >= 699340587 OR t_id_in >= 699340587 OR t_id_in IS NULL;
