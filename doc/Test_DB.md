# Test DB

Test set is to price DB availability.

To skip any test just rename corresponded *.sql to not end with '.sql'.

## Sample

Intel G3450 (2&times;3.4GHz), RAM 4G, HDD, 250kbk:

Test |Table| Time
-----|-----|-----:
sum_txo | raw | 34
sum_txo | txo | 11
top | raw | 295
top | txo | 12
utxo | raw | 538
utxo_no0 | raw | 567
utxo_noM | raw | 716
utxo | txo | 68
