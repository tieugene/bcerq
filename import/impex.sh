# Tool import bce2 output into SQL DB
# Requires: psql/mariadb-import, pigz/unpigz
# load/save: separate only, reload: +=z

declare -A table
table=([a]="addr" [b]="bk" [t]="tx" [v]="vout" [z]="addr,bk,tx,vout")
declare -A fields
fields=([a]="id,name,qty" [b]="id,datime" [t]="id,b_id,hash" [v]="t_id,n,money,a_id,t_id_in")

dbname=""
dbuser=""
tmpdir="."
# dn=`dirname $0`
cfgname=~/.bcerq.ini

help() {
  echo "Usage: $0 <cmd> <table> [<infile.gz>]
  cmd:
    filter: filter input data to stdout
    load:   load db from stdin
    xmit:   transmit input data into db
  table:
    a:  addr
    b:  bk
    t:  tx
    v:  vout
    z:  *"
  exit
}

chk_table() {
  # check given table name
  if [[ ! "abtvz" =~ $1 ]]; then
    echo "Bad <table> option '$1'"
    help
  fi
}

filter() {
  # TODO: argc, src exists; multiple src
  echo "Filtering '$1'" >> /dev/stderr
  case "$1" in
  a)
    unpigz -c $2 | grep ^$1 | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4}'
    ;;
  b)
    unpigz -c $2 | grep ^$1 | gawk -F "\t" -v OFS="\t" '{print $2,$3}'
    ;;
  t)
    unpigz -c $2 | grep ^$1 | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4}'
    ;;
  v)
    VOUTS=$tmpdir/o.txt.gz
    # 1. filter vouts (out_tx, out_n, satoshi, addr)
    unpigz -c $2 | grep ^o | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4,$5}' | pigz -c > $VOUTS
    # 2. filter vins (out_tx, out_n, in_tx)
    # 3. sort vins by vouts
    # 4. join vouts | vins
    unpigz -c $2 | grep ^i | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4}' | sort -n -k1 -k2 -T $tmpdir | python3 join_io.py $VOUTS
    # x. clean
    [ -f $VOUTS ] && rm -f $VOUTS
    ;;
  *)
    echo "Bad filter '$1'" >> /dev/stderr
    ;;
  esac
}

load() {
  # TODO: chk stdin is empty (https://unix.stackexchange.com/questions/33049/how-to-check-if-a-pipe-is-empty-and-run-a-command-on-the-data-if-it-isnt)
  t=${table[$1]}
  f=${fields[$1]}
  echo "Loading table '$t'" >> /dev/stderr
  case $dbengine in
  m)
    mariadb --local-infile=1 -h $dbhost -u $dbuser -p$dbpass $dbname -e "LOAD DATA LOCAL INFILE '/dev/stdin' INTO TABLE $t FIELDS TERMINATED BY '\t' ($f);"
    ;;
  p)
    psql -q -c "COPY $t ($f) FROM STDIN;" -h $dbhost $dbname $dbuser
    ;;
  *)
    echo "Unknown backend '$dbengine'" >> /dev/stderr
    ;;
  esac
}

xmit() {
  if [ ! $1 = "z" ]; then
    echo "Transmit '$1'"
    filter $1 $2 | load $1
  else
    echo "Transmit all"
    filter a $2 | load a
    filter b $2 | load b
    filter t $2 | load t
    filter v $2 | load v
  fi
}

# 1. chk options
[ $# -lt "2" ] && help
# 2. chk cfg
if [ ! -f "$cfgname" ]; then
  echo "Please fill '$cfgname' (dbhost=..., dbname=..., dbuser=..., tmpdir=...)"
  exit 1
fi
source $cfgname
# 3. go
chk_table $2
case "$1" in
  filter)
    if [[ ! "abtv" =~ $2 ]]; then
      echo "Bad <table> option '$2'. 'abtv' only"
      help
    fi
    if [ $# != "3" ]; then
      echo "Requires source .tgz" >> /dev/stderr
      exit
    fi
    filter  $2 $3
    ;;
  load)
    if [[ ! "abtv" =~ $2 ]]; then
      echo "Bad <table> option '$2'. 'abtv' only"
      help
    fi
    load $2
    ;;
  xmit)
    if [ $# != "3" ]; then
      echo "Requires <source>.txt.gz" >> /dev/stderr
      exit
    fi
    xmit $2 $3;;
  *)
    echo "Bad <cmd> '$1'"
    help
    ;;
esac
