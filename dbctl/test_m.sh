test_one() {
  echo "$1 $2"
  ./bcedb.py $1 $2
}

test_up() {
  for cmd in drop create idx wash show; do
    test_one $cmd a
    test_one $cmd b
    test_one $cmd t
    test_one $cmd v
  done
}

test_down() {
  for cmd in unidx trunc drop; do
    test_one $cmd v
    test_one $cmd t
    test_one $cmd b
    test_one $cmd a
  done
}

test_up
test_down
