# WorkFlow

Typical workflow to use bcerq utility set:

1. Config DBS  
  _install and configure PostgreSQL server and client also database and corresponding DB user according to [documentation](DBS.md) (manually)._.

1. Prepare `~/.bcerq.ini`  
   _create `~/.bcerq.ini` similar to [sample](bcerq.ini) (manually)._

1. Create DB scheme  
   _create DB tables according to [documentation](DB.md) using `bcedb.py`_
1. Load data  
   _import data according to [documentation](ImpEx.md) using `txt2tsv.sh` and `tsv2db.sh`;_
   _then index and valuum DB using `bcedb.py`_
1. Check (option)  
   _it is possible to make tests and benchmarks to estimate DB usability using [tests](../tests/)_
1. Queries  
   _main job according to [documentation](BCERQ.md) using `bcerq.py`_

----

![Comics](WorkFlow.svg)

_([source](WorkFlow.dot))_
