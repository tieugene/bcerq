#!/bin/sh
# Initial DB loading.
# 1. making bitcoind text data
CFG_FILE="$(dirname "$0")/init.cfg"
if [ -f "$CFG_FILE" ]; then . "$CFG_FILE"; else echo "$CFG_FILE not found"; exit; fi
[ -z "$KBK_COUNT" ] && (echo "KBK_COUNT not defied"; exit)
./bce2 -f 0 -n "$KBK_COUNT"000 -o 2>"$LOGDIR"/000-"$KBK_COUNT".log | zstd > "$TXTDIR"/000-"$KBK_COUNT".txt.zst
