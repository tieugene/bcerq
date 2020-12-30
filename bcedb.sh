# Tool to manipulate bce SQL database.
# TODO: verbose

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

dbhost=""
dbname=""
dbuser=""
dbpass=""
verbose=""
cfgname="$HOME/.bcerq.ini"
SQL_DIR="sql/dbctl"

help() {
  echo "Usage: $0 [-h <host>] [-d <db>] [-u <user>] [-p <pass>] <command> [<table>]
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
  psql -q -c "$1" -h "$dbhost" "$dbname" "$dbuser"
}

exec_cmd() {
  # exec cmd $2 for table $1
  #echo "Do: $dbscheme/$1/$2"
  sql_string=""
  sql_file=$SQL_DIR/$1/$2.sql
  if [ -f "$sql_file" ]; then
    sql_string=$(cat "$sql_file")
  else
    "Cannot find '$sql_file'"
    exit 1
  fi
  SQL="BEGIN;
$sql_string
COMMIT;"
  exec_sql "$SQL"
}

[ $# -lt "1" ] && help
# 1. load defaults
if [ -f "$cfgname" ]; then
  source "$cfgname"
fi
# 2. get CLI
while getopts h:d:u:p: opt
do
    case "${opt}" in
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
  TBL=$(ls "$SQL_DIR" | sort -r)
else
  TBL=$(ls "$SQL_DIR" | sort)
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
