-- 3. Count addrs and sum balances on a [date>bk>]tx by burtinity
-- 4'40" @ 450k (183759444)
-- 2'18" @ 450k/730k
-- 4'8" @ 2022-03-31 (722043870); 10'30"/3'30 (const from db)
-- Output: qid | count | sum
SELECT
  CASE
    WHEN total BETWEEN 1 AND 10^5 THEN 1
    WHEN total BETWEEN 1+10^5 AND 10^6 THEN 2
    WHEN total BETWEEN 1+10^6 AND 10^7 THEN 3
    WHEN total BETWEEN 1+10^7 AND 10^8 THEN 4
    WHEN total BETWEEN 1+10^8 AND 10^9 THEN 5
    WHEN total BETWEEN 1+10^9 AND 10^10 THEN 6
    WHEN total BETWEEN 1+10^10 AND 10^11 THEN 7
    WHEN total BETWEEN 1+10^11 AND 10^12 THEN 8
    WHEN total BETWEEN 1+10^12 AND 10^13 THEN 9
    WHEN total BETWEEN 1+10^13 AND 10^14 THEN 10
    WHEN total > 10^14 THEN 11
  END AS qid,
  COUNT(*),
  SUM(total)
FROM (
  SELECT
    a_id,
    SUM(money) AS total
  FROM
    vout
  WHERE
    t_id <= 183759444 AND
    (t_id_in > 183759444 OR t_id_in IS NULL) AND
    a_id IS NOT NULL AND
    money > 0
  GROUP BY
    a_id
) AS buratinos
GROUP BY 1
ORDER BY 1;
