test_one() {
  echo "$1 $2"
  ./bcedb.py $1 $2
}

for cmd in drop create idx wash show; do
  test_one $cmd a
  test_one $cmd v
done
for cmd in unidx trunc drop; do
  test_one $cmd v
  test_one $cmd a
done
