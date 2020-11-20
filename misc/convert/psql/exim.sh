source ~/.bcerqrc

# 1. mk db
do_query() {
  psql -h $DBHOST -f $1 $DBNAME $DBUSER
}

TIMEFORMAT=%R
echo -n "0. prepare db: "
time do_query c.sql
echo -n "2. exim data: "
time do_query e.sql
echo -n "3. idx all: "
time do_query i.sql
