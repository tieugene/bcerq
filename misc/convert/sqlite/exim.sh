DBPATH=tmp.sqlite3
source ~/.bcerqrc

# 1. mk db
mk_db() {
  cat c_a.sql c_d.sql
}

mk_idx() {
  cat i_a.sql i_d.sql
}

exim_a() {
  echo "DELETE FROM addr;"
  psql -h $DBHOST -f e_a.sql -t --no-align -F "," $DBNAME $DBUSER \
  | sed -e 's/^/INSERT INTO addr (id, name) VALUES(/' -e 's/$/);/'
}

exim_d() {
  echo "DELETE FROM data;"
  psql -h $DBHOST -f e_d.sql -t --no-align -F "," $DBNAME $DBUSER \
  | sed -e 's/^/INSERT INTO data (a_id, date0, date1, satoshi) VALUES(/' -e 's/$/);/' -e 's/,,/,NULL,/'
}

TIMEFORMAT=%R
echo "0. prepare db"
mk_db | sqlite3 $DBPATH
echo "1. exim addr"
time exim_a | sqlite3 $DBPATH
echo "2. exim data"
time exim_d | sqlite3 $DBPATH
echo "3. idx all"
time mk_idx | sqlite3 $DBPATH
