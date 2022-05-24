#!/bin/bash
# Direct update RDB from bitcoind
# configs: /etc/bce/aio.cfg, ~/.aio.cfg
# 'journalctl -t AIO' for syslog monitoring
CFG_NAME="aio.conf"
[ -f "/etc/bce/$CFG_NAME" ] && source "/etc/bce/$CFG_NAME"
[ -f "$HOME/.$CFG_NAME" ] && source "$HOME/.$CFG_NAME"
[ -z "$BINDIR" ] && { echo "No config found"; exit 1; }
TXT2SQL="$BINDIR/txt2sql.py"
ERRFILE="$ERRDIR/$(date +"%y%m%d%H%M%S").log"
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

process_bk() {
    # Process one block no $1
    bitcoin-cli getblock $(bitcoin-cli getblockhash "$1") 0 | tee >(zstd > "$HEXDIR/$1.hex.zst") | \
    bce2 -v1 -c -o -f "$1" -n 1 2>"$LOGDIR/$1.log" | tee >(zstd > "$TXTDIR/$1.txt.zst") | \
    $TXT2SQL | tee >(zstd > "$SQLDIR/$1.sql.zst") | \
    echo "BEGIN; $(cat) COMMIT;" | psql -q "$PGBASE" "$PGLOGIN"
}

:>"$ERRFILE"
log "== Start =="
# 0. Prepare
# - bce2
BK_KV=$(bce2 -i | grep ^Chk_bk | gawk '{print $2}')
[ -z "$BK_KV" ] && { log "Cannot ask bce2"; exit 1; }
# - bitcoind
chk_svc bitcoin || exit 1
# - postgresql
chk_svc postgresql || exit 1
# - blockchain
BK_BTC=$(bitcoin-cli getblockcount)
[ -z "$BK_BTC" ] && { log "Cannot ask btcd"; exit 1; }
# 1. main
if [ "$BK_KV" -lt "$BK_BTC" ]; then
  if [ -n "$BK_2ADD" ]; then BK_MAX=$((BK_KV+BK_2ADD-1)); else BK_MAX=$((BK_BTC-1)); fi
  log "Updating $BK_KV ... $BK_MAX required"
  for i in $(seq "$BK_KV" "$BK_MAX"); do process_bk "$i"; done
  log "Stat..."
  cat $(dirname "$0")/../sql/stat/{u_stat_bk.sql,u_stat_bk_inc.sql,u_stat_date.sql,u_stat_date_inc.sql} | psql -q -v ON_ERROR_STOP=on "$PGBASE" "$PGLOGIN"
  TAIL_FROM=$(date -d "-3 month -1 day" +"%Y-%m-%d")
  log "Tail (from $TAIL_FROM)"
  psql -q -c "CALL _tail_refill('$TAIL_FROM')" "$PGBASE" "$PGLOGIN"
  Q1A_DATE=$(date -d "-1 day" +"%Y-%m-%d")
  log "Q1A ($Q1A_DATE)"
  psql -q -c "CALL _daily('$Q1A_DATE')" "$PGBASE" "$PGLOGIN"
fi
log "== End =="
mail -S "from=$MAILFROM" -s "aio" "$MAILTO" < "$ERRFILE"
