#!/bin/sh
# Initial DB loading.
# 2. Export bce2 data to TSVs
CFG_FILE="$(dirname "$0")/init.cfg"
if [ -f "$CFG_FILE" ]; then . "$CFG_FILE"; else echo "$CFG_FILE not found"; exit; fi
mkdir -p "$TSVDIR/$KBK_COUNT"
for i in v a t b
do
  ("$BINDIR"/txt2tsv.sh $i "$TXTDIR"/000-"$KBK_COUNT".txt.zst | zstdmt > "$TSVDIR/$KBK_COUNT"/$i.tsv.zst)&
done
wait
