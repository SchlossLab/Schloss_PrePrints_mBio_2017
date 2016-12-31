mkdir -p data/biorxiv_disqus

COUNT=1
JSON_FILE=`printf "data/biorxiv_disqus/page_%03d.json" $COUNT`

curl -0 -L "https://disqus.com/api/3.0/threads/list.json?forum=biorxivstage&api_key=dPSyWIvAfhv6eiYaJOAQzHbXJ4RB51NuvkkcjQK0fQWrgLSA84ZEaF57cSIkEKXl&limit=100" -o $JSON_FILE

CURSOR=`sed 's/.*"next":"\([^"]*\)".*/\1/' $JSON_FILE`
HAS_NEXT=`sed 's/.*"hasNext":\([^,]*\).*/\1/' $JSON_FILE`


while [ $HAS_NEXT == "true" ]; do

	COUNT=$(($COUNT+1))
	JSON_FILE=`printf "data/biorxiv_disqus/page_%03d.json" $COUNT`

	curl -0 -L "https://disqus.com/api/3.0/threads/list.json?forum=biorxivstage&api_key=dPSyWIvAfhv6eiYaJOAQzHbXJ4RB51NuvkkcjQK0fQWrgLSA84ZEaF57cSIkEKXl&limit=100&cursor=$CURSOR" -o $JSON_FILE

	CURSOR=`sed 's/.*"next":"\([^"]*\)".*/\1/' $JSON_FILE`
	HAS_NEXT=`sed 's/.*"hasNext":\([^,]*\).*/\1/' $JSON_FILE`
	echo $HAS_NEXT $COUNT $CURSOR
done
