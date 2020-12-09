-- export addresses
SELECT
	a_id AS id,
	a_list AS name
FROM addresses
WHERE
	jsonb_typeof(a_list) = 'string'
ORDER BY
	a_id;
