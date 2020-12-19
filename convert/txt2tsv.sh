# Tool to export bce2 output into SQL loadable CSV
# Requires: pigz/unpigz
# TODO: scheme
# TODO: v | tee (remove tmp file)

tmpdir="."
cfgname=~/.bcerq.ini

help() {
  echo "Usage: $0 <table> <infile1.txt.gz> [<infile2.txt.gz> ... ]
  table:
    a:  addr
    b:  bk
    t:  tx
    v:  vout"
  exit
}

ex() {
  # $1: table character
  # $2+: files
  echo "Export '$1'" >> /dev/stderr
  TABLE=$1
  shift 1
  case "$TABLE" in
  a)
    unpigz -c $@ | grep ^$TABLE | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4}'
    ;;
  b)
    unpigz -c $@ | grep ^$TABLE | sed "s/'//g" | gawk -F "\t" -v OFS="\t" '{print $2,$3}'
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

# 1. chk options
[ $# -lt "1" ] && help
if [ $# -lt "2" ]; then
  echo "Requires <sources>.txt.tgz" >> /dev/stderr
  exit
fi
# 2. chk table
if [[ ! "abtv" =~ $1 ]]; then
  echo "Bad <table> option '$1'. 'abtv' only"
  help
fi
# 3. go
ex $@
