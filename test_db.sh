# mis benchmarks

TIMEFORMAT=%R
cfgname="$HOME/.bcerq.ini"
source "$cfgname"
BASE_DIR=`dirname "$0"`
SQL_DIR="$BASE_DIR/sql/test"

test_pgsql() {
  # $1 - query name
  DST="`basename $1 .sql`.csv"
  echo -n "`basename $1` `head -n 1 $1`: "
  sec=`time psql -q -f "$1" -t --no-align -F $'\t' -h "$dbhost" "$dbname" "$dbuser" > tmp/$DST`
  echo -n "$sec" >> /dev/stderr
}

for i in `ls $SQL_DIR/*.sql`
do
  	test_pgsql $i
done
