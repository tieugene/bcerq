#!/bin/sh
# Tool to manipulate bce interim data
# Requires: psql, pigz

declare -A table
table=([a]="addresses" [b]="blocks" [t]="transactions" [d]="data" [z]="blocks,transactions,addresses,data")
declare -A fields
fields=([a]="a_id,a_list,n" [b]="b_id,b_time" [t]="t_id,b_id,hash" [d]="t_out_id,t_out_n,satoshi,a_id,t_in_id")

dbname=""
dbuser=""
tmpdir="."
dn=`dirname $0`
cfgname=$dn/.db_ctl.cfg

function help() {
  echo "Usage: $0 <cmd> <table> [<infile.gz>]
  cmd:
    drop:   drop table
    create: create table
    show:   show table structure
    trunc:  delete all records
    idxoff: delete all indices and constraints
    idxon:  create all indices and constraints
    vacuum: vacuum table
    filter: filter input data to stdout
    load:   load db from stdin
    reload: fully reload table[s] from blockchain export
  table:
    b:  blocks
    t:  transactions
    a:  addresses
    d:  data
    z:  all"
  exit
}

function chk_table() {
  # check given table name
  if [[ ! "btadz" =~ $1 ]]; then
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
    cat $dn/sql/{ca.sql,cb.sql,ct.sql,cd.sql} | psql -q $dbname $dbuser
  fi
}

function idxoff() {
  if [ ! $1 = "z" ]; then
    t=$dn/sql/u$1.sql
    echo "Drop indices of '${table[$1]}' from '$t'."
    psql -q -f $t $dbname $dbuser
  else
    echo "Drop all indices."
    cat $dn/sql/{ud.sql,ut.sql,ub.sql,ua.sql} | psql -q $dbname $dbuser
  fi
}

function idxon() {
  if [ ! $1 = "z" ]; then
    t=$dn/sql/i$1.sql
    echo "Create indices of '${table[$1]}' from '$t'."
    psql -q -f $t $dbname $dbuser
  else
    echo "Create all indices."
    cat $dn/sql/{ia.sql,ib.sql,it.sql,id.sql} | psql -q $dbname $dbuser
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

function filter() {
  # TODO: argc, src exists; multiple src
  echo "Filter by '$1'" >> /dev/stderr
  case "$1" in
  a)
    unpigz -c $2 | grep ^$1 | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4}';;
  b)
    unpigz -c $2 | grep ^$1 | gawk -F "\t" -v OFS="\t" '{print $2,$3}';;
  t)
    unpigz -c $2 | grep ^$1 | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4}';;
  d)
    # 1. filter vouts (out_tx, out_n, satoshi, addr)
    unpigz -c $2 | grep ^o | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4,$5}' | pigz -c > $tmpdir/o.txt.gz
    # 2. filter vins (out_tx, out_n, in_tx)
    # 3. sort vins by vouts
    unpigz -c $2 | grep ^i | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4}' | sort -n -k1 -k2 -T $tmpdir | pigz -c > $tmpdir/i.txt.gz
    # 4. join vouts | vins
    python3 join_io.py $tmpdir/o.txt.gz $tmpdir/i.txt.gz && rm -f $tmpdir/{i,o}.txt.gz;;
  *)
    echo "Bad filter '$1'";;
  esac
}

function load() {
  # TODO: chk stdin is empty (https://unix.stackexchange.com/questions/33049/how-to-check-if-a-pipe-is-empty-and-run-a-command-on-the-data-if-it-isnt)
  t=${table[$1]}
  f=${fields[$1]}
  echo "Load table '$t'" >> /dev/stderr
  psql -q -c "COPY $t ($f) FROM STDIN;" $dbname $dbuser
}

function reload() {
  if [ ! $1 = "z" ]; then
    echo "reloading '$1'"
    idxoff $1
    trunc $1
    vacuum $1
    filter $1 $2 | load $1
    # vacuum $1
    idxon $1
    vacuum $1
  else
    echo "reloading all"
    idxoff z
    trunc z
    vacuum z
    filter a $2 | load a
    filter b $2 | load b
    filter t $2 | load t
    filter d $2 | load d
    # vacuum z
    idxon z
    vacuum z
  fi
}

# 1. chk options
[ $# -lt "2" ] && help
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
  filter)
    if [[ ! "btad" =~ $2 ]]; then
      echo "Bad <table> option '$2'. 'abtd' only"
      help
    fi
    if [ $# != "3" ]; then
      echo "Requires source .tgz" >> /dev/stderr
      exit
    fi
    filter  $2 $3;;
  load)
    if [[ ! "btad" =~ $2 ]]; then
      echo "Bad <table> option '$2'. 'abtd' only"
      help
    fi
    load    $2;;
  reload)
    if [ $# != "3" ]; then
      echo "Requires source .tgz" >> /dev/stderr
      exit
    fi
    reload   $2 $3;;
  *)
    echo "Bad <cmd> '$1'"
    help;;
esac
