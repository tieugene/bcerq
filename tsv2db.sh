# Tool to import TSV data into SQL DB
# Requires: psql
# TODO: common ./functions.sh
# TODO: load ./pgpass

# const
declare -A tbl_array
tbl_array=([a]="addr" [b]="bk" [t]="tx" [v]="vout")
declare -A fld_array
fld_array=([a]="id,name,qty" [b]="id,datime" [t]="id,b_id,hash" [v]="t_id,n,money,a_id,t_id_in")
CFG_NAME="bcerq.conf"
# var
dbhost=""
dbname=""
dbuser=""
dbpass=""
verbose=0

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
  message "Usage: $0 [-h <host>] [-d <db>] [-u <user>] [-p <pass>] <table>
  table:
    a:  addr
    b:  bk
    t:  tx
    v:  vout"
  exit
}

im() {
  # import stdin into tbl_array $1:char
  t=${tbl_array[$1]}
  f=${fld_array[$1]}
  if [ -z "$f" ]; then
    message "Can't find fields for table '$1'."
    exit 1
  fi
  debug "Import table '$t'"
  psql -q -c "COPY $t ($f) FROM STDIN;" -h "$dbhost" "$dbname" "$dbuser"
}

# 1. load defaults
# 1.1. cfg
[ -f "/etc/bce/$CFG_NAME" ] && source "/etc/bce/$CFG_NAME"
[ -f "$HOME/.$CFG_NAME" ] && source "$HOME/.$CFG_NAME"
# 1.2. get CLI
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
# 1.x. TODO: chk mandatory
# 2. positional option
[ $# -lt "1" ] && help
if [[ ! "abtv" =~ $1 ]]; then
  message "Bad table '$1'."
  help
fi
# 3. go
im "$1"
