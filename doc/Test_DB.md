# Test DB

Test set is to price DB availability.

To skip any test just rename corresponded *.sql to not end with '.sql'.

## Sample

Intel G3450 (2&times;3.4GHz), RAM 4G, HDD, 250kbk:

Test |Table| Time | Desc
-----|-----|-----:|-----
sum_txo | raw | 34 | Sum of all TXO of whole DB
| | txo | 11
top | raw | 295 | Top 50 buratinos on 2013-06-01
| | txo | 12
utxo | raw | 538 | UTXO monthly
utxo_no0 | raw | 567 | UTXO monthly (excluding addressless)
utxo_noM | raw | 716 | UTXO monthly (single address only)
utxo | txo | 68
