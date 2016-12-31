mkdir -p data/biorxiv_altmetric

SUFFIX=`cat data/biorxiv_doi_urls.tsv | cut -f 5 -d /`

for DOI in $SUFFIX
do
	curl -o data/biorxiv_altmetric/$DOI.json http://api.altmetric.com/v1/doi/10.1101/$DOI?key=992a953baa805c06d19db4c2b6bb1348
	sleep 0.5s
done
