echo "bash code/get_pp_pages.sh 0 5000
bash code/get_pp_pages.sh 5000 10000
bash code/get_pp_pages.sh 10000 15000
bash code/get_pp_pages.sh 15000 20000
bash code/get_pp_pages.sh 20000 25000
bash code/get_pp_pages.sh 25000 30000
bash code/get_pp_pages.sh 30000 35000
bash code/get_pp_pages.sh 35000 40000
bash code/get_pp_pages.sh 40000 45000
bash code/get_pp_pages.sh 45000 50000
bash code/get_pp_pages.sh 50000 55000
bash code/get_pp_pages.sh 55000 60000
bash code/get_pp_pages.sh 60000 65000
bash code/get_pp_pages.sh 65000 70000
bash code/get_pp_pages.sh 70000 75000
bash code/get_pp_pages.sh 75000 80000
bash code/get_pp_pages.sh 80000 85000
bash code/get_pp_pages.sh 85000 90000
bash code/get_pp_pages.sh 90000 95000
bash code/get_pp_pages.sh 95000 100000" > get_pp_pages.qsub

split -l 1 get_pp_pages.qsub pp_
for file in pp_a?
do
	cat head.qsub $file tail.qsub > $file.qsub
	qsub $file.qsub
	rm $file*
done

rm get_pp_pages.qsub

