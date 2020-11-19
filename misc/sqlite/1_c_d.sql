-- 1_c_d.sql - create vouts table
CREATE TABLE IF NOT EXISTS data (
	a_id INTEGER NOT NULL,
	date0 INTEGER NOT NULL,
	date1 INTEGER NULL,
	satoshi INTEGER NOT NULL,
	FOREIGN KEY (a_id)
       REFERENCES addr (id)
       	ON DELETE CASCADE
);
