# Tool to import CSV into SQL DB
# Requires: psql/mariadb
# TODO: mk common .sh (options, vars)

declare -A table
table=([a]="addr" [b]="bk" [t]="tx" [v]="vout")
declare -A fields
fields=(
  [af]="id,name,qty" [bf]="id,datime" [tf]="id,b_id,hash" [vf]="t_id,n,money,a_id,t_id_in"
  [am]="id,name" [bm]="id,datime" [tm]="id,b_id" [vm]="t_id,n,money,a_id,t_id_in"
  [at]="id,name" [vt]="a_id,date0,date1,money"
)

dbscheme=""
dbengine=""
dbhost=""
dbname=""
dbuser=""
dbpass=""
cfgname="$HOME/.bcerq.ini"

help() {
  echo "Usage: $0 [-s <schema>] [-e <engine>] [-h <host>] [-d <db>] [-u <user>] [-p <pass>] <table>
  schema:
    f:  full
    m:  midi
    t:  tiny
  engine:
    m:  MySQL
    p:  PostgreSQL
  table:
    a:  addr
    b:  bk
    t:  tx
    v:  vout" >> /dev/stderr
  exit
}

im() {
  t=${table[$1]}
  f=${fields[$1$dbscheme]}
  if [ -z "$f" ]; then
    echo "Can't find fields for table '$1' and schema '$dbscheme'." >> /dev/stderr
    exit 1
  fi
  echo "Import table '$t'" >> /dev/stderr
  case $dbengine in
  m)
    mariadb --local-infile=1 -h "$dbhost" -u "$dbuser" -p"$dbpass" "$dbname" -e "LOAD DATA LOCAL INFILE '/dev/stdin' INTO TABLE $t FIELDS TERMINATED BY '\t' ($f);"
    ;;
  p)
    psql -q -c "COPY $t ($f) FROM STDIN;" -h "$dbhost" "$dbname" "$dbuser"
    ;;
  *)
    echo "Unknown db engine '$dbengine'" >> /dev/stderr
    ;;
  esac
}

[ $# -lt "1" ] && help
# 1. load defaults
if [ -f "$cfgname" ]; then
  source "$cfgname"
fi
# 2. get CLI
while getopts s:e:h:d:u:p: opt
do
    case "${opt}" in
        s)
          if [[ ! "fmt" =~ ${OPTARG} ]]; then
            echo "Bad schema '${OPTARG}'." >> /dev/stderr
            exit 1
          fi
          dbscheme=${OPTARG}
          ;;
        e)
          if [[ ! "mp" =~ ${OPTARG} ]]; then
            echo "Bad db engine '${OPTARG}'." >> /dev/stderr
            exit 1
          fi
          dbengine=${OPTARG}
          ;;
        h) dbhost=${OPTARG};;
        d) dbname=${OPTARG};;
        u) dbuser=${OPTARG};;
        p) dbpass=${OPTARG};;
        *) help;;
    esac
done
shift $((OPTIND-1))
# TODO: chk result
# if [ -z dbscheme ] | ...; do
#   echo "Use options or fill out 'cfgname'."
#   exit 1
# fi
# 3. chk positional option
if [[ ! "abtv" =~ $1 ]]; then
  echo "Bad <table> '$1'."
  help
fi
# 3. go
im "$1"
