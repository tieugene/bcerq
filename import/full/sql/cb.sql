-- blocks
CREATE TABLE IF NOT EXISTS blocks (
	b_id INT NOT NULL PRIMARY KEY,
	b_time TIMESTAMP NOT NULL
);
CREATE INDEX IF NOT EXISTS idx_blocks_b_time ON blocks (b_time);
