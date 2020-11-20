source ~/.bcerqrc

do_query() {
  psql -h $DBHOST -f $1 -q $DBNAME $DBUSER
}

TIMEFORMAT=%R
echo -n "0. prepare db: "
time do_query c.sql
echo -n "2. export data: "
time do_query e.sql | pigz -c > data.txt.gz
echo -n "3. import data: "
time unpigz -c data.txt.gz | psql -h $DBHOST -c "COPY txo FROM STDIN" -q $DBNAME $DBUSER
echo -n "4. idx all: "
time do_query i.sql
