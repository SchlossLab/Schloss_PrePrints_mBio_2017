#!/bin/bash

for i in {0..100000}
do
	DOI_URL=`printf "http://dx.doi.org/10.1101/%06d" $i`

	BIORXIV_URL=`curl -L -o /dev/null --silent --head --write-out '%{url_effective}\n' $DOI_URL`

	if [ "$BIORXIV_URL" != "$DOI_URL" ]
	then
		wget -N ${BIORXIV_URL} -P data/dois/
		wget -N ${BIORXIV_URL}.article-info -P data/dois/
		wget -N ${BIORXIV_URL}.article-metrics -P data/dois/
	fi
done
