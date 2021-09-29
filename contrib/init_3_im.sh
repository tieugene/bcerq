#!/bin/sh
# Import data fromo TSVs to SQL DB
BCEDB=/mnt/shares/GIT/bcerq/bcedb.sh
$BCEDB unidx z
$BCEDB trunc z
for i in a b t v
do
  (zstdcat /mnt/btc/tsv/450/$i.tsv.zst | /mnt/shares/GIT/bcerq/tsv2db.sh $i)&
done
