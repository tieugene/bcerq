#!/bin/sh
# Xload SQL
BCEDB=/mnt/shares/GIT/bcerq/bcedb.sh
$BCEDB unidx x && \
$BCEDB trunc x && \
$BCEDB xload x && \
$BCEDB idx x
