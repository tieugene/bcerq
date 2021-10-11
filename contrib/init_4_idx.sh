#!/bin/sh
# Initial DB loading.
# 3. Index tables
CFG_FILE="$(dirname "$0")/init.cfg"
if [ -f "$CFG_FILE" ]; then . "$CFG_FILE"; else echo "$CFG_FILE not found"; exit; fi
"$BINDIR"/bcedb.sh idx z
