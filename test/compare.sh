for i in `ls asis/out`; do
diff -du asis/out/$i psql/out/$i
done
