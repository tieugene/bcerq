-- t_1a_date: Table of calculated results for queries of 2021-10-15
CREATE TABLE IF NOT EXISTS t_1a_date (
  d DATE NOT NULL,        -- date
  qid SMALLINT NOT NULL,  -- query id
  rid SMALLINT NOT NULL,  -- range of buratinity id
  val BIGINT NOT NULL     -- query result
);
CREATE INDEX IF NOT EXISTS t_1a_date_d_idx ON t_1a_date (d);
CREATE INDEX IF NOT EXISTS t_1a_date_rid_idx ON t_1a_date (rid);
CREATE INDEX IF NOT EXISTS t_1a_date_qid_idx ON t_1a_date (qid);
ALTER TABLE t_1a_date ADD CONSTRAINT t_1a_date_pkey PRIMARY KEY (d, rid, qid);
