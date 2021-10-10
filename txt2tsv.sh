# Tool to export bce2 output into SQL loadable CSV
# Requires: zstdmt/zstdcat, gzip|pigz
# TODO: v | tee (remove tmp file)
# TODO: i+o => v(i+o)+u
# tmp: macOS: TMP_DIR, Windows: TEMP/TMP, Linux: /tmp

CFG_NAME="bcerq.conf"
BASE_DIR=$(dirname "$0")
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
  message "Usage: $0 [-v] [-t <tmpdir>] <table> <infile1.txt.zst> [<infile2.txt.zst> ... ]
  Options:
  -v          - verbose
  -t <tmpdir> - folder to store temporary file (default=here or from $CFG_NAME)
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
    zstdcat -T0 $@ | grep ^"$TABLE" | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4}'
    ;;
  b)
    zstdcat -T0 $@ | grep ^"$TABLE" | sed "s/'//g" | gawk -F "\t" -v OFS="\t" '{print $2,$3}'
    ;;
  t)
    zstdcat -T0 $@ | grep ^"$TABLE" | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4}'
    ;;
  v)
    VOUTS=$tmpdir/o.txt.gz
    # 1. filter vouts (out_tx, out_n, satoshi, addr)
    zstdcat -T0 $@ | grep ^o | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4,$5}' | pigz -c > $VOUTS
    # 2. filter vins (out_tx, out_n, in_tx)
    # 3. sort vins by vouts
    # 4. join vouts | vins
    zstdcat -T0 $@ | grep ^i | gawk -F "\t" -v OFS="\t" '{print $2,$3,$4}' | sort -n -k1 -k2 -T $tmpdir | python3 "$BASE_DIR/join_io.py" $VOUTS
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
[ -f "/etc/bce/$CFG_NAME" ] && source "/etc/bce/$CFG_NAME"
[ -f "$HOME/.$CFG_NAME" ] && source "$HOME/.$CFG_NAME"
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
  message "Requires <sources>.txt.zst"
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
