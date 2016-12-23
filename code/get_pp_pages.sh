#!/bin/bash

# This takes the six digit article suffix name as input...

mkdir -p data/biorxiv

LOCAL_FILE=$1

DOI_URL=`echo $LOCAL_FILE | sed "s=data/biorxiv/=http://dx.doi.org/10.1101/="`

BIORXIV_URL=`curl -L -o /dev/null --silent --head --write-out '%{url_effective}\n' $DOI_URL`

phantomjs code/save_page.js ${BIORXIV_URL} > $LOCAL_FILE
wget -N ${BIORXIV_URL}.article-info -P data/biorxiv/
wget -N ${BIORXIV_URL}.article-metrics -P data/biorxiv/

if [ -f ${BIORXIV_URL}.[12].article-info ];
then
	mv ${BIORXIV_URL}.[12].article-info ${BIORXIV_URL}.article-info
fi

if [ -f ${BIORXIV_URL}.[12].article-metrics ];
then
	mv ${BIORXIV_URL}.[12].article-metrics ${BIORXIV_URL}.article-metrics
fi
