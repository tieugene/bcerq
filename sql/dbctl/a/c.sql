-- addr.c
CREATE UNLOGGED TABLE IF NOT EXISTS addr (
	id INT NOT NULL,
	name JSONB NOT NULL,
	qty INT NOT NULL
);