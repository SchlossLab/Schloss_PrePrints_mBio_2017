mkdir -p data/altmetric

for DOI in data/dois/??????
do
	SUFFIX=`echo $DOI | sed "s=data/dois/=="`
	curl -o data/altmetric/$SUFFIX.json http://api.altmetric.com/v1/doi/10.1101/$SUFFIX?key=992a953baa805c06d19db4c2b6bb1348

	sleep 1s
done
