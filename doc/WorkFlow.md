# WorkFlow

Workflow example

Datum:

- bce2' data: tsv/{a,b,t,v}.tsv.gz
- pwd: bcerq git folder

# 1. fill ~/,bcerq.ini

# 2. Config DBS

# 3. Create DB

# 4. Prepare DB scheme

```
dbctl/bcedb.py create
```

# 5. Load data

```
for i in a b t v; do unpigz -c tsv/$i.tsv.gz | impex/tsv2db.sh $i; done
dbtcl/bcedb.py idx
```

# 7. Test/benchmark

# 8. Queries
