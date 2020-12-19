-- addr, f2m/f2t
SELECT id, JSON_UNQUOTE(name) FROM addr WHERE qty = 1 ORDER BY id;
