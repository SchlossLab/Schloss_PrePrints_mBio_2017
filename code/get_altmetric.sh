mkdir -p data/altmetric

SUFFIX=`cat data/doi_urls.txt | cut -f 5 -d /`

for DOI in $SUFFIX
do
	curl -o data/altmetric/$DOI.json http://api.altmetric.com/v1/doi/10.1101/$DOI?key=992a953baa805c06d19db4c2b6bb1348
	sleep 0.5s
done
