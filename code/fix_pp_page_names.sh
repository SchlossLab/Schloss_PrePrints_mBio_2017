#	This script will remove the random appearing .1. and .2. in the article-info
# and article-metrics file names after downloading from biorxiv

for FILE in data/dois/*.?.*
do
	NEW=`echo $FILE | sed "s/\\.[12]././"`
	mv $FILE $NEW
done
