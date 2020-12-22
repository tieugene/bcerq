#!/usr/bin/env bash
# test queries from misc backend/scheme

TIMEFORMAT=%R
cfgname="$HOME/.bcerq.ini"
source "$cfgname"

test_mysql() {
  # $1 - scheme
  # $2 - query
  sec=`time mariadb -N -h "$dbhost" -u "$dbuser" -p"$dbpass" btcdb"$1" < sql/m/$2.sql > tsv/m/"$2".csv`
  echo -n "MySQL ($1/$2): $sec" >> /dev/stderr
}

test_pgsql() {
  # $1 - scheme
  # $2 - query
  sec=`time psql -q -f sql/p/"$2".sql -t --no-align -F $'\t' -h "$dbhost" btcdb"$1" "$dbuser" > tsv/p/"$2".csv`
  echo -n "PgSQL ($1/$2): $sec" >> /dev/stderr
}

# for SCRIPT in test_mysql test_pgsql; do
SCRIPT="test_pgsql"
$SCRIPT f utxo_f
$SCRIPT f utxo_f_date
$SCRIPT f utxo_f_no0
$SCRIPT f utxo_f_no0_date
$SCRIPT f utxo_f_noM
$SCRIPT f utxo_f_noM_date
$SCRIPT m utxo_m
$SCRIPT t utxo_t
$SCRIPT f top_fm
$SCRIPT f top_f_date
$SCRIPT f top_fm_view
$SCRIPT m top_fm
$SCRIPT m top_fm_view
$SCRIPT t top_t
# done
