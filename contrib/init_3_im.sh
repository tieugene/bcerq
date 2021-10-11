#!/bin/sh
# Initial DB loading.
# 3. Import TSVs into RDB
CFG_FILE="$(dirname "$0")/init.cfg"
if [ -f "$CFG_FILE" ]; then . "$CFG_FILE"; else echo "$CFG_FILE not found"; exit; fi
"$BINDIR"/bcedb.sh unidx z
"$BINDIR"/bcedb.sh trunc z
for i in a b t v
do
  (zstdcat "$TSVDIR/$KBK_COUNT"/$i.tsv.zst | "$BINDIR"/tsv2db.sh $i)&
done
wait
