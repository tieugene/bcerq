-- Ranges
CREATE TEMPORARY TABLE IF NOT EXISTS ranges (
  id SMALLINT NOT NULL PRIMARY KEY,
  b BIGINT NOT NULL UNIQUE,
  e BIGINT NOT NULL UNIQUE
);
INSERT INTO ranges (id, b, e)
VALUES
  ( 1, 1, 10^5),
  ( 2, 1+10^5, 10^6),
  ( 3, 1+10^6, 10^7),
  ( 4, 1+10^7, 10^8),
  ( 5, 1+10^8, 10^9),
  ( 6, 1+10^9, 10^10),
  ( 7, 1+10^10, 10^11),
  ( 8, 1+10^11, 10^12),
  ( 9, 1+10^12, 10^13),
  (10, 1+10^13, 10^14),
  (11, 1+10^14, 9223372036854775807);
