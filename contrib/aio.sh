#!/bin/sh
# Direct update RDB from bitcoind
# Usage:
# $0 - update RDB
# $0 <yyyy-mm-dd> - +xload from date
# $0 <anything> - +xload all
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

postlog() {
    echo "$1" | tee -a "$ERRFILE"
}

log() {
    echo "$(date +"%y-%m-%d %H:%M:%S"): $1" | tee -a "$ERRFILE"
}

chk_svc() {
    # check service is active
    prelog "Check $1..."
    systemctl is-active --quiet "$1"
    retcode=$?
    if [ $retcode -eq 0 ]; then postlog "works"; else postlog "stopped"; fi
    return $retcode
}

start_svc() {
    # try to start service
    prelog "Start $1..."
    sudo systemctl start "$1"
    retcode=$?
    if [ $retcode -eq 0 ]; then postlog "OK"; else postlog "Fail"; fi
    return $retcode
}

stop_svc() {
    # try to stop service
    prelog "Start $1..."
    sudo systemctl stop "$1"
    retcode=$?
    if [ $retcode -eq 0 ]; then postlog "OK"; else postlog "Fail"; fi
    return $retcode
}

process_bk() {
    # Process one block no $1
    bitcoin-cli getblock $(bitcoin-cli getblockhash "$1") 0 | tee >(zstd > "$HEXDIR/$1.hex.zst") | \
    bce2 -v1 -c -o -f "$1" -n 1 2>"$LOGDIR/$1.log" | tee >(zstd > "$TXTDIR/$1.txt.zst") | \
    $TXT2SQL | tee >(zstd > "$SQLDIR/$1.sql.zst") | \
    echo "BEGIN; $(cat) COMMIT;" | psql -q "$PGBASE" "$PGLOGIN"
}

xload() {
  SAMPLE="^20[0-9]{2}-[0-9]{2}-[0-9]{2}$"
  $BCEDB unidx x && $BCEDB trunc x && (\
    if [[ $1 =~ $SAMPLE ]]; then
      prelog "Reload TXO from $1..."
      SQL=$(python3 "$BINDIR/xload.py" -f "$1")
      psql -q -c "$SQL" "$BTCDB" "$BTCUSER"
    else
      prelog "Full reload TXO..."
      $BCEDB xload x
    fi
    postlog "OK"; prelog "Index TXO..."; $BCEDB idx x\
  )
  postlog "OK"
}

:>"$ERRFILE"
if [ -z "$1" ]; then log "== Start =="; else log "== Start with '$1' =="; fi
exit
# 0. Prepare
# - bce2
BK_KV=$(bce2 -i | grep ^Chk_bk | gawk '{print $2}')
[ -z "$BK_KV" ] && (log "Cannot ask bce2"; exit 1)
# - bitcoin
chk_svc bitcoin && SVC_BTC="1"
if [ -z "$SVC_BTC" ]; then
  start_svc bitcoin || exit 1
  prelog "Wait..."
  sleep 10
  postlog "OK"
fi
# - blockchain
BK_BTC=$(bitcoin-cli getblockcount)
[ -z "$BK_BTC" ] && (log "Cannot ask btcd"; exit 1)
if [ "$BK_KV" -lt "$BK_BTC" ]; then
  if [ -n "$BK_2ADD" ]; then let "BK_MAX=$BK_KV+$BK_2ADD-1"; else let "BK_MAX=$BK_BTC-1"; fi
  log "Updating $BK_KV ... $BK_MAX required"
  chk_svc postgresql && SVC_SQL="1"
  if [ -z "$SVC_SQL" ]; then start_svc postgresql || exit 1; fi
  prelog "Updating..."
  for i in $(seq "$BK_KV" "$BK_MAX"); do process_bk "$i"; done
  postlog "OK"
  if [ -n "$1" ]; then
    stop_svc bitcoin
    xload "$1"
    [ -z "$SVC_SQL" ] && stop_svc postgresql
    [ -n "$SVC_BTC" ] && start_svc bitcoin
  else
    [ -z "$SVC_SQL" ] && stop_svc postgresql
  fi
fi
[ -z "$SVC_BTC" ] && stop_svc bitcoin
log "== End =="
mail -s "BTC update" "$MAILTO" < "$ERRFILE"
