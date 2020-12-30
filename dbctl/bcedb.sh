# Tool to manipulate bce SQL database.

declare -A cmd_array
cmd_array=(
  [create]="c"
  [idx]="i"
  [unidx]="u"
  [show]="s"
  [wash]="w"
  [trunc]="t"
  [drop]="d"
)

cfgname="$HOME/.bcerq.ini"
dbscheme=""
dbengine=""
dbhost=""
dbname=""
dbuser=""
dbpass=""
verbose=""

help() {
  echo "Usage: $0 [-s <schema>] [-b <backend>] [-h <host>] [-d <db>] [-u <user>] [-p <pass>] <command> [<table>]
  schema:
    f:  full
    m:  midi
    t:  tiny
  backend:
    m:  MySQL
    p:  PostgreSQL
  command:
    create: create table
    idx:    create indices and constraints
    unidx:  drop indices and constraints
    show:   show table info
    wash:   wash up table (vacuum/optimize)
    trunc:  delete all data
    drop:   drop table
  table (all if omit):
    a:  addr
    b:  bk
    t:  tx
    v:  vout" >> /dev/stderr
  exit
}

exec_sql() {
  # Exec $1 sql string
  case $dbengine in
  m)
    mariadb -e "$1" -h "$dbhost" -u "$dbuser" -p"$dbpass" "$dbname"
    ;;
  p)
    psql -q -c "$1" -h "$dbhost" "$dbname" "$dbuser"
    ;;
  *)
    echo "Unknown db engine '$dbengine'" >> /dev/stderr
    ;;
  esac
}

exec_cmd() {
  # exec cmd $2 for table $1
  #echo "Do: $dbscheme/$1/$2"
  sql_common=""
  sql_file=$dbscheme/$1/$2.sql
  if [ -f "$sql_file" ]; then
    sql_common=$(cat "$sql_file")
  fi
  sql_spec=""
  sql_file=$dbscheme/$1/$dbengine/$2.sql
  if [ -f "$sql_file" ]; then
    sql_spec=$(cat "$sql_file")
  fi
  SQL="BEGIN;
$sql_common
$sql_spec
COMMIT;"
  exec_sql "$SQL"
}

[ $# -lt "1" ] && help
# 1. load defaults
if [ -f "$cfgname" ]; then
  source "$cfgname"
fi
# 2. get CLI
while getopts s:e:h:d:u:p: opt
do
    case "${opt}" in
        s)
          if [[ ! "fmt" =~ ${OPTARG} ]]; then
            echo "Bad schema '${OPTARG}'." >> /dev/stderr
            exit 1
          fi
          dbscheme=${OPTARG}
          ;;
        e)
          if [[ ! "mp" =~ ${OPTARG} ]]; then
            echo "Bad db engine '${OPTARG}'." >> /dev/stderr
            exit 1
          fi
          dbengine=${OPTARG}
          ;;
        h) dbhost=${OPTARG};;
        d) dbname=${OPTARG};;
        u) dbuser=${OPTARG};;
        p) dbpass=${OPTARG};;
        *) help;;
    esac
done
shift $((OPTIND-1))
# TODO: chk result
# 3. chk positional option
# 3.1. cmd
[ $# -lt "1" ] && help
CMD=${cmd_array[$1]}
if [ -z "$CMD" ]; then
  echo "Bad <command> '$1'."
  help
fi
# 3.2. table
if [[ "dtu" =~ $CMD ]]; then
  TBL=$(ls "$dbscheme" | sort -r)
else
  TBL=$(ls "$dbscheme" | sort)
fi
if [ $# -gt "1" ]; then
  if [[ ! "$TBL" =~ $2 ]]; then
    echo "Bad <table> '$2'."
    help
  else
    TBL=$2
  fi
fi
# 3. go
for t in $TBL; do
  exec_cmd "$t" "$CMD"
done
#im "$1"
