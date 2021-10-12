#!/bin/bash
# Direct update RDB from bitcoind
# Usage:
# $0 - update RDB
# $0 <yyyy-mm-dd> - +xload from date
# $0 <anything> - +xload all
# configs: /etc/bce/aio.cfg, ~/.aio.cfg
# 'journalctl -t AIO' for syslog monitoring
CFG_NAME="aio.conf"
[ -f "/etc/bce/$CFG_NAME" ] && source "/etc/bce/$CFG_NAME"
[ -f "$HOME/.$CFG_NAME" ] && source "$HOME/.$CFG_NAME"
[ -z "$BINDIR" ] && { echo "No config found"; exit 1; }
TXT2SQL="$BINDIR/txt2sql.py"
BCEDB="$BINDIR/bcedb.sh"
ERRFILE="$ERRDIR/$(date +"%y%m%d%H%M%S").log"
SVC_BTC=""
SVC_SQL=""
PRELOG=""

prelog() {
  PRELOG=$1
  echo -n "$(date +"%y-%m-%d %H:%M:%S"): $1" | tee -a "$ERRFILE"
}

postlog() {
  echo "$1" | tee -a "$ERRFILE"
  logger -t AIO "$PRELOG$1"
}

log() {
  echo "$(date +"%y-%m-%d %H:%M:%S"): $1" | tee -a "$ERRFILE"
  logger -t AIO "$1"
}

chk_svc() {
  # check service is active
  prelog "Check $1..."
  systemctl is-active --quiet "$1"
  retcode=$?
  if [ $retcode -eq 0 ]; then postlog "works"; else postlog "stopped"; fi
  return $retcode
}

do_svc() {
    # try to systemctls service
    # $1 - action, $2 - service
    prelog "$1 $2..."
    sudo systemctl "$1" "$2"
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
  $BCEDB unidx x && $BCEDB trunc x && {
    if [[ $1 =~ $SAMPLE ]]; then
      log "Reload TXO from $1 start"
      SQL=$(python3 "$BINDIR/xload.py" -f "$1")
      psql -q -c "$SQL" "$PGBASE" "$PGLOGIN"
    else
      log "Reload TXO start"
      $BCEDB xload x
    fi
    log "Reload TXO end. Indexing start"
    $BCEDB idx x
    log "Indexing end"
  }
}

:>"$ERRFILE"
if [ -z "$1" ]; then log "== Start =="; else log "== Start with '$1' =="; fi
# 0. Prepare
# - bce2
BK_KV=$(bce2 -i | grep ^Chk_bk | gawk '{print $2}')
[ -z "$BK_KV" ] && { log "Cannot ask bce2"; exit 1; }
# - bitcoin
chk_svc bitcoin && SVC_BTC="1"
if [ -z "$SVC_BTC" ]; then
  do_svc start bitcoin || exit 1
  prelog "Wait..."
  sleep 10
  postlog "OK"
fi
# - blockchain
BK_BTC=$(bitcoin-cli getblockcount)
[ -z "$BK_BTC" ] && { log "Cannot ask btcd"; exit 1; }
if [ "$BK_KV" -lt "$BK_BTC" ]; then
  if [ -n "$BK_2ADD" ]; then BK_MAX=$((BK_KV+BK_2ADD-1)); else BK_MAX=$((BK_BTC-1)); fi
  log "Updating $BK_KV ... $BK_MAX required"
  chk_svc postgresql && SVC_SQL="1"
  if [ -z "$SVC_SQL" ]; then do_svc start postgresql || exit 1; fi
  log "Update start"
  for i in $(seq "$BK_KV" "$BK_MAX"); do process_bk "$i"; done
  log "Update end"
  if [ -n "$1" ]; then
    do_svc freeze bitcoin
    xload "$1"
    do_svc thaw bitcoin
  fi
  [ -z "$SVC_SQL" ] && do_svc stop postgresql
fi
[ -z "$SVC_BTC" ] && do_svc stop bitcoin
log "== End =="
mail -S "from=$MAILFROM" -s "aio" "$MAILTO" < "$ERRFILE"
