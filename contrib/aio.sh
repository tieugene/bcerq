#!/bin/sh
# Update RDB from bitcoind
BASEDIR="/mnt/btc"
HEXDIR="$BASEDIR/hex"
TXTDIR="$BASEDIR/txt"
LOGDIR="$BASEDIR/log"
ERRDIR="$BASEDIR/log.cron"
SQLDIR="$BASEDIR/sql"
BINDIR="/mnt/shares/GIT/bcerq"
TXT2SQL="$BINDIR/txt2sql.py"
BCEDB="$BINDIR/bcedb.sh"
PGBASE="btcdb"
PGLOGIN="btcuser"
# ----
SVC_BTC=""
SVC_SQL=""
ERRFILE="$ERRDIR/$(date +"%y%m%d%H%M%S").log"
>$ERRFILE

prelog() {
    echo -n "$(date +"%y-%m-%d %H:%M:%S"): $1" | tee -a $ERRFILE
}

log() {
    echo "$(date +"%y-%m-%d %H:%M:%S"): $1" | tee -a $ERRFILE
}

chk_svc() {
    # check service is active
    # return: 0 (ok) if active
    log "Check $1 service"
    systemctl is-active --quiet $1
}

start_svc() {
    # try to start service
    log "Starting $1 service"
    sudo systemctl start $1; sleep 3; systemctl is-active --quiet $1
}

stop_svc() {
    # try to stop service
    log "Stoping $1 service"
    systemctl is-active --quiet $1 && sudo systemctl stop $1
}

process_bk() {
    # Process one block no $1
    bitcoin-cli getblock $(bitcoin-cli getblockhash $1) 0 | tee >(zstd > $HEXDIR/$1.hex.zst) | \
    bce2 -v1 -c -o -f $1 -n 1 2> $LOGDIR/$1.log | tee >(zstd > $TXTDIR/$1.txt.zst) | \
    $TXT2SQL | tee >(zstd > $SQLDIR/$1.sql.zst) | \
    echo "BEGIN; $(cat) COMMIT;" | psql -q $PGBASE $PGLOGIN
}

xload() {
    log "Reload TXO"
    $BCEDB unidx x && $BCEDB trunc x && $BCEDB xload x && (log "Index TXO"; $BCEDB idx x)
}

# 0. Prepare
log "== Start =="
# - bitcoin
chk_svc bitcoin && SVC_BTC="1" || start_svc bitcoin || exit 1
# - bce2
BK_KV=$(bce2 -i | grep ^Chk_bk | gawk '{print $2}')
# - blockchain
BK_BTC=$(bitcoin-cli getblockcount)
if [ "$BK_KV" -lt "$BK_BTC" ]; then
    # let "BK_MAX=$BK_BTC-1"
    let "BK_MAX=$BK_KV+9"
    chk_svc postgresql && SVC_SQL="1" || start_svc postgresql || exit 1
    log "Updating $BK_KV ... $BK_MAX"
    for i in $(seq $BK_KV $BK_MAX); do
        process_bk $i
    done
    if [ ! -z "$1" ]
    then
        stop_svc bitcoin
        xload
        [ -z "$SVC_SQL" ] && stop_svc postgresql
        [ ! -z "$SVC_BTC" ] && start_svc bitcoin
    else
        [ -z "$SVC_SQL" ] && stop_svc postgresql
    fi
fi
# x. closing
[ -z "$SVC_BTC" ] && stop_svc bitcoin
log "== End =="
cat $ERRFILE | mail -s "BTC update" ti.eugene@gmail.com
