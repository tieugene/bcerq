source ~/.bcerqrc

if [ $# -ne 1 ]; then
  echo "Usage: $0 <dir>"
  exit
fi
if [ ! -d $1 ]; then
  echo "$1 is not folder or not exists"
  exit
fi

TIMEFORMAT=%R
for i in `ls $1/sql`; do
  echo -n "$i: "
  time psql -h $DBHOST -f $1/sql/$i -o $1/out/`basename $i .sql`.txt $DBNAME $DBUSER
done
