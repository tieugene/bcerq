# Tool import bce2 output into SQL DB
# Requires: psql/mariadb-import, pigz/unpigz
# load/save: separate only, reload: +=z
# TODO: multiple *.txt.gz ($@, shift)

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
  echo "Usage: $0 <cmd> <table> [<infile1.txt.gz> <infile2.txt.gz> ... ]
  cmd:
    ex:   filter input data to stdout
    im:   load db from stdin
    xmit: transmit input data into db
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

ex() {
  # $1: table character
  # $2+: files
  # TODO: argc, src exists; multiple src
  echo "Export '$1'" >> /dev/stderr
  TABLE=$1
  shift 1
  case "$TABLE" in
  a)
    unpigz -c $@ | grep ^$TABLE | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4}'
    ;;
  b)
    unpigz -c $@ | grep ^$TABLE | gawk -F "\t" -v OFS="\t" '{print $2,$3}'
    ;;
  t)
    unpigz -c $@ | grep ^$TABLE | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4}'
    ;;
  v)
    VOUTS=$tmpdir/o.txt.gz
    # 1. filter vouts (out_tx, out_n, satoshi, addr)
    unpigz -c $@ | grep ^o | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4,$5}' | pigz -c > $VOUTS
    # 2. filter vins (out_tx, out_n, in_tx)
    # 3. sort vins by vouts
    # 4. join vouts | vins
    unpigz -c $@ | grep ^i | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4}' | sort -n -k1 -k2 -T $tmpdir | python3 join_io.py $VOUTS
    # x. clean
    [ -f $VOUTS ] && rm -f $VOUTS
    ;;
  *)
    echo "Bad filter '$TABLE'" >> /dev/stderr
    ;;
  esac
}

im() {
  # TODO: chk stdin is empty (https://unix.stackexchange.com/questions/33049/how-to-check-if-a-pipe-is-empty-and-run-a-command-on-the-data-if-it-isnt)
  t=${table[$1]}
  f=${fields[$1]}
  echo "Import table '$t'" >> /dev/stderr
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
  TABLE=$1
  shift 1
  if [ ! $TABLE = "z" ]; then
    echo "Transmit '$1'"
    ex $TABLE $@ | im $TABLE
  else
    echo "Transmit all"
    ex a $@ | im a
    ex b $@ | im b
    ex t $@ | im t
    ex v $@ | im v
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
CMD=$1
shift 1
case "$CMD" in
  ex)
    if [[ ! "abtv" =~ $1 ]]; then
      echo "Bad <table> option '$1'. 'abtv' only"
      help
    fi
    if [ $# -lt "2" ]; then
      echo "Requires <sources>.txt.tgz" >> /dev/stderr
      exit
    fi
    ex $@
    ;;
  im)
    if [[ ! "abtv" =~ $1 ]]; then
      echo "Bad <table> option '$1'. 'abtv' only"
      help
    fi
    im $1
    ;;
  xmit)
    if [ $# -lt "2" ]; then
      echo "Requires <sources>.txt.gz" >> /dev/stderr
      exit
    fi
    xmit $@
    ;;
  *)
    echo "Bad <cmd> '$CMD'"
    help
    ;;
esac
