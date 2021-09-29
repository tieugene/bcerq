#!/bin/sh
# Index tables
# Note: serial indexing only: (a,b>t)>v
BCEDB=/mnt/shares/GIT/bcerq/bcedb.sh
for i in a b t v; do $BCEDB idx $i; done
