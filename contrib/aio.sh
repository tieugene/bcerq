#!/bin/sh
# Direct update RDB from bitcoind
CFG_FILE="$(dirname "$0")/init.cfg"
if [ -f "$CFG_FILE" ]; then . "$CFG_FILE"; else echo "$CFG_FILE not found"; exit; fi
TXT2SQL="$BINDIR/txt2sql.py"
BCEDB="$BINDIR/bcedb.sh"
ERRFILE="$ERRDIR/$(date +"%y%m%d%H%M%S").log"
SVC_BTC=""
SVC_SQL=""

prelog() {
    echo -n "$(date +"%y-%m-%d %H:%M:%S"): $1" | tee -a "$ERRFILE"
}

log() {
    echo "$(date +"%y-%m-%d %H:%M:%S"): $1" | tee -a "$ERRFILE"
}

chk_svc() {
    # check service is active
    prelog "Check $1... "
    systemctl is-active --quiet $1
    retcode=$?
    if $retcode; then log "Err"; else log "OK"; fi
    return $retcode
}

start_svc() {
    # try to start service
    prelog "Start $1..."
    sudo systemctl start $1
    retcode=$?
    if $retcode; then log "Err"; else log "OK"; fi
    return $retcode
}

stop_svc() {
    # try to stop service
    log "Stoping $1 service"
    systemctl is-active --quiet $1 && sudo systemctl stop $1
}

process_bk() {
    # Process one block no $1
    bitcoin-cli getblock $(bitcoin-cli getblockhash $1) 0 | tee >(zstd > $HEXDIR/$1.hex.zst) | \
    bce2 -v1 -c -o -f "$1" -n 1 2>$LOGDIR/$1.log | tee >(zstd > $TXTDIR/$1.txt.zst) | \
    $TXT2SQL | tee >(zstd > $SQLDIR/$1.sql.zst) | \
    echo "BEGIN; $(cat) COMMIT;" | psql -q "$PGBASE" "$PGLOGIN"
}

xload() {
    log "Reload TXO"
    $BCEDB unidx x && $BCEDB trunc x && $BCEDB xload x && (log "Index TXO"; $BCEDB idx x)
}

:>"$ERRFILE"
log "== Start =="
# 0. Prepare
# - bce2
BK_KV=$(bce2 -i | grep ^Chk_bk | gawk '{print $2}')
[ -n "$BK_KV" ] && (log "Cannot ask bce2"; exit 1)
# - bitcoin
# FIXME: chk btcd started
chk_svc bitcoin && SVC_BTC="1"
[ -z "$SVC_BTC" ] && (start_svc bitcoin || (log "oops"; exit 1))
log "The end"
exit
# - blockchain
BK_BTC=$(bitcoin-cli getblockcount)
[ -z "$BK_BTC" ] && (log "Cannot ask btcd"; exit 1)
if [ "$BK_KV" -lt "$BK_BTC" ]; then
  if [ -z "$BK_2ADD" ]; then let "BK_MAX=$BK_KV+$BK_2ADD-1"; else let "BK_MAX=$BK_BTC-1"; fi
  log "Updating $BK_KV ... $BK_MAX"
  # FIXME: chk psql started
  chk_svc postgresql && SVC_SQL="1" || start_svc postgresql || exit 1
  for i in $(seq "$BK_KV" "$BK_MAX"); do
    process_bk $i
  done
  if [ -n "$1" ]; then
    stop_svc bitcoin
    xload
    [ -z "$SVC_SQL" ] && stop_svc postgresql
    [ -n "$SVC_BTC" ] && start_svc bitcoin
  else
    [ -z "$SVC_SQL" ] && stop_svc postgresql
  fi
fi
[ -z "$SVC_BTC" ] && stop_svc bitcoin
log "== End =="
cat "$ERRFILE" | mail -s "BTC update" "$MAILTO"
