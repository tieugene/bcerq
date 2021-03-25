# Test DB

Test set is to price DB availability.

To skip any test just rename corresponded *.sql to not end with '.sql'.

## Sample

1. Intel G3450 (2&times;3.4GHz), RAM 4GB, HDD, 250kbk
2. Intel i7-4790 (4&times;3.6GHz), RAM 32GB, HDD, 400kbk

Test     |Table|time1| time2| Desc
---------|-----|----:|-----:|-----
sum_txo  | raw |  34 |   98 | Sum of all TXO of whole DB
|        | txo |  11 |   11 |
top      | raw | 295 |  666 | Top 50 buratinos on 2013-06-01
|        | txo |  12 |   15 |
utxo     | raw | 538 | 1631 | UTXO monthly
utxo_no0 | raw | 567 | 1955 | UTXO monthly (excluding addressless)
utxo_noM | raw | 716 | 1658 | UTXO monthly (single address only)
utxo     | txo |  68 |  680 |
