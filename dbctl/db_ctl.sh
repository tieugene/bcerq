# Tool to manipulate bce SQL database
# Requires: psql/mysql

declare -A table
table=([a]="addr" [b]="bk" [t]="tx" [v]="vout" [z]="addr,bk,tx,vout")

dbngin=""
dbhost=""
dbname=""
dbuser=""
dn=`dirname $0`
cfgname="~/.db_ctl.cfg"

function help() {
  echo "Usage: $0 <cmd> [<table>]
  cmd:
    drop:   drop table
    create: create table
    show:   show table structure
    trunc:  delete all records
    idxoff: delete all indices and constraints
    idxon:  create all indices and constraints
    clean:  clean up table
  table:
    <dir>:  table
    z:  all"
  exit
}

function chk_table() {
  # check given table name
  if [[ ! "abtvz" =~ $1 ]]; then
    echo "Bad <table> option '$1'"
    help
  fi
}

# can be altogether
function drop() {
  t=${table[$1]}
  echo "Drop table[s] '$t'."
  psql -q -c "DROP TABLE $t;" $dbname $dbuser
}

function vacuum() {
  t=${table[$1]}
  echo "Vacuum table[s] '$t'."
  psql -q -c "VACUUM FULL $t;" $dbname $dbuser
}

function trunc() {
  t=${table[$1]}
  echo "Truncate table[s] '$t'."
  psql -q -c "TRUNCATE TABLE $t;" $dbname $dbuser
}

# separate
function create() {
  if [ ! $1 = "z" ]; then
    t=$dn/sql/c$1.sql
    echo "Create table '${table[$1]}'."
    psql -q -f $t $dbname $dbuser
  else
    echo "Create all tables."
    cat $dn/sql/{ca.sql,cb.sql,ct.sql,cv.sql} | psql -q $dbname $dbuser
  fi
}

function idxoff() {
  if [ ! $1 = "z" ]; then
    t=$dn/sql/u$1.sql
    echo "Drop indices of '${table[$1]}' from '$t'."
    psql -q -f $t $dbname $dbuser
  else
    echo "Drop all indices."
    cat $dn/sql/{uv.sql,ut.sql,ub.sql,ua.sql} | psql -q $dbname $dbuser
  fi
}

function idxon() {
  if [ ! $1 = "z" ]; then
    t=$dn/sql/i$1.sql
    echo "Create indices of '${table[$1]}' from '$t'."
    psql -q -f $t $dbname $dbuser
  else
    echo "Create all indices."
    cat $dn/sql/{ia.sql,ib.sql,it.sql,iv.sql} | psql -q $dbname $dbuser
  fi
}

function show() {
  # RTFM: https://www.postgresqltutorial.com/postgresql-describe-table/
  # TODO: z == ?
  t=${table[$1]}
  echo "Show '$t'"
  # pg_dump $dbname -t $t --schema-only -U $dbuser
  # psql \d, \dt \d+
}

# 1. chk options
[ $# -lt "1" ] && help
# 2. chk cfg
if [ ! -f "$cfgname" ]; then
  echo "Please fill '$cfgname' (dbname=..., dbuser=..., tmpdir=...)"
  exit 1
fi
source $cfgname
# 3. go
chk_table $2
case "$1" in
  drop)
    drop    $2;;
  vacuum)
    vacuum  $2;;
  trunc)
    trunc   $2;;
  create)
    create  $2;;
  idxoff)
    idxoff  $2;;
  idxon)
    idxon   $2;;
  show)
    show    $2;;
  *)
    echo "Bad <cmd> '$1'"
    help;;
esac
