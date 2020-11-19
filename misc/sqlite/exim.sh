#!/bin/sh
DBPATH=tmp.sqlite3
PSQLHOST="localhost"
BTCDB=btcdb
BTCUSER=btcuser

# 1. mk db
mk_db() {
  cat 1_c_a.sql 1_c_d.sql
}

mk_idx() {
  cat 3_i_a.sql 3_i_d.sql
}

exim_a() {
  echo "DELETE FROM addr;"
  psql -h $PSQLHOST -f 2_e_a.sql -t --no-align -F "," $BTCDB $BTCUSER \
  | sed -e 's/^/INSERT INTO addr (id, name) VALUES(/' -e 's/$/);/'
}

exim_d() {
  echo "DELETE FROM data;"
  psql -h $PSQLHOST -f 2_e_d.sql -t --no-align -F "," $BTCDB $BTCUSER \
  | sed -e 's/^/INSERT INTO data (a_id, date0, date1, satoshi) VALUES(/' -e 's/$/);/' -e 's/,,/,NULL,/'
}

mk_db | sqlite3 $DBPATH
exim_a | sqlite3 $DBPATH
exim_d | sqlite3 $DBPATH
mk_idx | sqlite3 $DBPATH
