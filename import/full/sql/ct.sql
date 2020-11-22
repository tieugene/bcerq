-- transactions
CREATE TABLE IF NOT EXISTS transactions (
	t_id INT NOT NULL PRIMARY KEY,
	hash CHAR(64) NOT NULL UNIQUE,
	b_id INT NOT NULL REFERENCES blocks(b_id)
);
CREATE INDEX IF NOT EXISTS idx_transactions_b_id ON transactions (b_id);
