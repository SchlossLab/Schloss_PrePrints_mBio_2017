mkdir -p data/asm_altmetric

SUFFIX=`cat data/asm_doi_urls.tsv | cut -f 5 -d / | cut -f 1`

for DOI in $SUFFIX
do
	curl -o data/asm_altmetric/$DOI.json http://api.altmetric.com/v1/doi/10.1128/$DOI?key=992a953baa805c06d19db4c2b6bb1348
	sleep 0.25s
done
