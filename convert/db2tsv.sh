# Tool to convert SQL DB into CSV
# Requires: psql/mariadb
# Input: src (cfg), dst schema/table
# Output: csv > stdout
# TODO: DB connection options
# TODO: mariadb -S <socket_path>

declare -A tsd_array
tsd_array=(
  # full to ...
  [aff]="a_ff" [afm]="a_f_" [aft]="a_f_"
  [bff]="b_xx" [bfm]="b_fm"
  [tff]="t_ff" [tfm]="t__m"
  [vff]="v_ff" [vfm]="v_fm" [vft]="v_ft"
  # midi to ...
  [amm]="a_yy" [amt]="a_yy"
  [bmm]="b_xx"
  [tmm]="t__m"
  [vmm]="v_mm" [vmt]="v_mt"
  # tiny to tiny
  [att]="a_yy"
  [vtt]="v_tt"
)

cfgname="$HOME/.bcerq.ini"

help() {
  echo "Usage: $0 <table> <scheme>
  table:
    a:    addr
    b:    bk
    t:    tx
    v:    vout
  scheme (dst):
    f:    full
    m:    midi
    t:    tiny
  " >> /dev/stderr
  exit
}

ex() {
  # @param $1: table (short)
  # @param $2: dst schema
  TSD_KEY="$1$dbscheme$2"   # Table/Source_schema/Dst_schema == key
  TSD_FILE=${tsd_array[$TSD_KEY]}
  if ! [ $TSD_FILE ]; then
    echo "Converting '$1: $dbscheme > $2' not defined." >> /dev/stderr
    exit 1
  fi
  TSD_PATH="$dbengine/$TSD_FILE.sql"
  if ! [ -f $TSD_PATH ]; then
    echo "Converter '$TSD_PATH' not exists." >> /dev/stderr
    exit 1
  fi
  echo "Export '$1: $dbscheme > $2'." >> /dev/stderr
  # exit
  case $dbengine in
  m)
    mariadb -N -h $dbhost -u $dbuser -p$dbpass $dbname < "$TSD_PATH" | sed 's/\\\\N/\\N/g'
    ;;
  p)
    psql -q -f "$TSD_PATH" -h $dbhost $dbname $dbuser
    ;;
  *)
    echo "Unknown backend '$dbengine'" >> /dev/stderr
    ;;
  esac
}

# 1. chk options
[ $# -ne "2" ] && help
if [[ ! "abtv" =~ $1 ]]; then
  echo "Unknown dest table '$1'." >> /dev/stderr
  exit 1
fi
if [[ ! "fmt" =~ $2 ]]; then
  echo "Unknown dest schema '$2'." >> /dev/stderr
  exit 1
fi
# 2. chk cfg
if [ ! -f "$cfgname" ]; then
  echo "Please fill '$cfgname' (dbhost=..., dbname=..., dbuser=..., tmpdir=...)" >> /dev/stderr
  exit 1
fi
source $cfgname
# 3. go
ex $1 $2
