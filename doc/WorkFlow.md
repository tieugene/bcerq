# WorkFlow

Typical workflow to use bcerq utility set:

1. Config DBS  
  _install and configure PostgreSQL server, client, database and DB user manually ([RTFM](DBS.md))._

1. Prepare `~/.bcerq.ini`  
   _create `~/.bcerq.ini` similar to [sample](bcerq.ini) (manually)._

1. Create DB scheme  
   _create DB tables using `bcedb.sh` ([RTFM](DB.md))._  
   _e.g.: `./bcedb.sh create {a,b,t,v}`_
1. Load data  
   _import data using `txt2tsv.sh` and `tsv2db.sh` ([RTFM](ImpEx.md));_  
   _then index and valuum DB using `bcedb.sh`_
1. Check (optional)  
   _it is possible to make tests and benchmarks to estimate DB usability using [tests](../tests/)_
1. Queries  
   _main job using `bcerq.py` ([RTFM](BCERQ.md))_

----

![Comics](WorkFlow.svg)

_([source](WorkFlow.dot))_
