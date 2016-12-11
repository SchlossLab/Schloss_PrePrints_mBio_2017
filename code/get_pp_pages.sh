#!/bin/bash

for i in {0..100000}
do
	DOI_URL=`printf "http://dx.doi.org/10.1101/%06d" $i`

	BIORXIV_URL=`curl -L -o /dev/null --silent --head --write-out '%{url_effective}\n' $DOI_URL`

	if [ "$BIORXIV_URL" != "$DOI_URL" ]
	then
		phantomjs code/save_page.js ${BIORXIV_URL} > `printf "data/dois/%06d" $i`
		phantomjs code/save_page.js ${BIORXIV_URL}.article-info > `printf "data/dois/%06d.article-info" $i`
		phantomjs code/save_page.js ${BIORXIV_URL}.article-metrics > `printf "data/dois/%06d.article-metrics" $i`
	fi
done
