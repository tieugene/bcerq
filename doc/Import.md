# Import

Format: tab-separated, `\N` as NULL, w/o field names.

Actions:

- data &rArr; *.csv.gz (`unpigz *.txt.gz | from ? | pigz -c > *.tsv.gz`
- *.csv.gz &rArr; DB (`upigz -c *.tsv.gz | to ?`)
- data &rArr; DB (`unpigz *.txt.gz | from ? | to ?`)

DB:

- PostgreSQL (```COPY <table> FROM STDIN;```)
- MySQL (```LOAD DATA LOCAL INFILE '/dev/sdtdi' INTO TABLE <table>;```)

Scheme:

- full
- midi
- tiny

## Full

Imported as is: 4 tables, vout with nullable addrs and multiaddr

## Midi

- addr: _!multisig_
- bk: shrink date
- tx: del hash
- vout: w/o !addr, w/o multisig, w/o money=0
