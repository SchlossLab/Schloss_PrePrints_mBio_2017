#!/bin/bash

SUFFIX=$1

DOI_URL=http://dx.doi.org/10.1101/$SUFFIX

BIORXIV_URL=`curl -L -o /dev/null --silent --head --write-out '%{url_effective}\n' $DOI_URL`
LOCAL_FILE=`echo $DOI_URL | sed "s=http://dx.doi.org/10.1101/=data/biorxiv/=g"`

phantomjs code/save_page.js ${BIORXIV_URL} > $LOCAL_FILE
wget -N ${BIORXIV_URL}.article-info -P data/dois/
wget -N ${BIORXIV_URL}.article-metrics -P data/dois/

if [ -f ${BIORXIV_URL}.[12].article-info ];
then
	mv ${BIORXIV_URL}.[12].article-info ${BIORXIV_URL}.article-info
fi

if [ -f ${BIORXIV_URL}.[12].article-metrics ];
then
	mv ${BIORXIV_URL}.[12].article-metrics ${BIORXIV_URL}.article-metrics
fi
