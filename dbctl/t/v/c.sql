-- t.vout
-- PRIMARY KEY (a_id, date0, date1)
CREATE TABLE IF NOT EXISTS vout (
	a_id INT NOT NULL,
	date0 DATE NOT NULL,
	date1 DATE,
	money BIGINT NOT NULL
);
