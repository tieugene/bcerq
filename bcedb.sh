# Tool to manipulate bce SQL database.
# …TODO: bulk sql B2in BEGIN; ... COMMIT;
# …TODO: verbose
# …TODO: chk options (dbname dbuser)
# TODO: txo = c|u|t|cp2|i|w
# TODO: common ./functions.sh
# TODO: load ./pgpass

# const
declare -A cmd_array
cmd_array=(
  [create]="c"
  [idx]="i"
  [unidx]="u"
  [show]="s"
  [wash]="w"
  [trunc]="t"
  [drop]="d"
  [xload]="x"
)
declare -A tbl_array
tbl_array=(
  [a]="addr"
  [b]="bk"
  [t]="tx"
  [v]="vout"
  [x]="txo"
)
cfgname="$HOME/.bcerq.ini"
BASE_DIR=`dirname "$0"`
SQL_DIR="$BASE_DIR/sql/dbctl"
# var
dbhost=""
dbname=""
dbuser=""
dbpass=""
verbose=""

message() {
  # print message
  echo "$1" >> /dev/stderr
}

debug() {
  if [ -n "$verbose" ]; then
    message "$1"
  fi
}

help() {
  message "Usage: $0 [-h <host>] [-d <db>] [-u <user>] [-p <pass>] <command> <table>
  command:
    create: create table
    idx:    create indices and constraints
    unidx:  drop indices and constraints
    show:   show table info
    wash:   wash up table (vacuum)
    trunc:  delete all data
    drop:   drop table
    xload:  trans-load txo from other tables ('x' table only)
  table (all if omit):
    a:  addr
    b:  bk
    t:  tx
    v:  vout
    x:  txo
    z:  all of them"
  exit
}

load_sql() {
  # load SQL for cmd $1 for table $2 (short)
  T_FULL=${tbl_array[$2]}
  SQL=""
  case $1 in
    d) SQL="DROP TABLE $T_FULL;";;
    s) SQL="SELECT * FROM information_schema.columns WHERE table_name = '$T_FULL';";;
    t) SQL="TRUNCATE TABLE $T_FULL;";;
    w) SQL="VACUUM ANALYZE $T_FULL;";;
    *)
      sql_file=$SQL_DIR/$2/$1.sql
      if [ -f "$sql_file" ]; then
        SQL=$(cat "$sql_file")
      else
        message "Cannot find '$sql_file'"
        exit 1
      fi
      ;;
  esac
  echo "$SQL"
}

# 1. load defaults
# 1.1. defaults
if [ -f "$cfgname" ]; then
  source "$cfgname"
fi
# 1.2. CLI
while getopts vh:d:u:p: opt
do
  case "${opt}" in
    v) verbose=1;;
    h) dbhost=${OPTARG};;
    d) dbname=${OPTARG};;
    u) dbuser=${OPTARG};;
    p) dbpass=${OPTARG};;
    *) help;;
  esac
done
shift $((OPTIND-1))
# 1.3. TODO: ~/.pgpass
# 1.x. chk mandatory
if [ -z dbname ] || [ -z dbuser ]; then
  message "'dbname' or 'dbuser' no defined. Use -d/-u option or fill out '$cfgname'"
fi
# 2. positional options
# 2.1. cmd
[ $# -lt "2" ] && help
CMD=${cmd_array[$1]}
if [ -z "$CMD" ]; then
  message "Bad <command> '$1'."
  help
fi
# 2.2. table
if [[ "dtu" =~ $CMD ]]; then  # drop/trunc/unidx in reverse order
  TBL=$(ls "$SQL_DIR" | sort -r)
else
  TBL=$(ls "$SQL_DIR" | sort)
fi
if [[ "$2" != "z" ]]; then
  if [[ "$TBL" =~ $2 ]]; then
    TBL=$2
  else
    message "Bad table name '$2'."
    help
  fi
fi
# 3. prepare SQLs
for t in $TBL; do
  SQL+=$(load_sql $CMD $t)
done
# v2: [ "dtu" =~ $CMD ] ...
# SQL="BEGIN;\n$SQL\nCOMMIT;"
# 4. go
debug "Exec '$SQL'"
psql -q -c "$SQL" -h "$dbhost" "$dbname" "$dbuser"
