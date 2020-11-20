-- 1_c_d.sql - create vouts table
CREATE TABLE IF NOT EXISTS txo (
	a_id BIGINT NOT NULL REFERENCES addresses(a_id),
	date0 DATE NOT NULL,
	date1 DATE NULL,
	satoshi BIGINT NOT NULL
);
