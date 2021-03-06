# Tool to export bce2 output into SQL loadable CSV
# Requires: pigz/unpigz
# TODO: v | tee (remove tmp file)
# TODO: i+o => v(i+o)+u
# tmp: macOS: TMP_DIR, Windows: TEMP/TMP, Linux: /tmp

cfgname="$HOME/.bcerq.ini"
BASE_DIR=`dirname "$0"`
tmpdir="."
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
  message "Usage: $0 [-v] [-t <tmpdir>] <table> <infile1.txt.gz> [<infile2.txt.gz> ... ]
  Options:
  -v          - verbose
  -t <tmpdir> - folder to store temporary file (default=here or from $cfgname)
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
  # message "Export '$1'"
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
    unpigz -c $@ | grep ^i | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4}' | sort -n -k1 -k2 -T $tmpdir | python3 "$BASE_DIR/join_io.py" $VOUTS
    # x. clean
    [ -f $VOUTS ] && rm -f $VOUTS
    ;;
  *)
    message "Bad table '$TABLE'"
    ;;
  esac
}

# 1. load defaults
# 1.1. defaults
if [ -f "$cfgname" ]; then
  source "$cfgname"
fi
# 1.2. CLI
while getopts t: opt
do
  case "${opt}" in
    v) verbose=1;;
    t) tmpdir=${OPTARG};;
    *) help;;
  esac
done
shift $((OPTIND-1))
# 2. positional options
# 2.1. cmd
[ $# -lt "1" ] && help
if [ $# -lt "2" ]; then
  message "Requires <sources>.txt.tgz"
  exit
fi
# 2.2. chk table
if [[ ! "abtv" =~ $1 ]]; then
  message "Bad table '$1'. 'abtv' only"
  help
fi
# 3. go
debug "Processing $1"
ex $@
