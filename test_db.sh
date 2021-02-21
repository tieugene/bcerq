#!/usr/bin/env bash
# test queries from misc backend/scheme

TIMEFORMAT=%R
cfgname="$HOME/.bcerq.ini"
source "$cfgname"
BASE_DIR=`dirname "$0"`
SQL_DIR="$BASE_DIR/sql/test"

test_pgsql() {
  # $1 - query name
  sec=`time psql -q -f "$SQL_DIR/$1".sql -t --no-align -F $'\t' -h "$dbhost" "$dbname" "$dbuser" > tmp/"$1".csv`
  echo -n "PgSQL ($1): $sec" >> /dev/stderr
}

for i in `ls -1 $SQL_DIR/*.sql | grep sql$`
do
  test_pgsql $i
done
