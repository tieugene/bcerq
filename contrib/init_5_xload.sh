#!/bin/sh
# Initial DB loading.
# 5. Xload TXO
BCEDB=$BINDIR/bcedb.sh
$BCEDB unidx x && \
$BCEDB trunc x && \
$BCEDB xload x && \
$BCEDB idx x
