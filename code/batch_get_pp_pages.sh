N_DOIS=`wc -l data/dois/doi_urls.txt | cut -f 1 -d ' '`


START=1

> get_pp_pages.qsub
while [[ $START -le $N_DOIS ]]
do
	END=$(($START+249))
	if [ "$END" -gt "$N_DOIS" ]
	then
		END=$N_DOIS
	fi
	echo "bash code/get_pp_pages.sh $START $END" >> get_pp_pages.qsub
	((START = START + 250))
done

split -l 1 get_pp_pages.qsub pp_
for file in pp_a?
do
	cat head.qsub $file tail.qsub > $file.qsub
	qsub $file.qsub
	rm $file*
done

rm get_pp_pages.qsub
