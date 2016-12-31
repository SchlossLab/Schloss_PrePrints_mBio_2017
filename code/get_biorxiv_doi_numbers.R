#https://github.com/CrossRef/rest-api-doc/blob/master/rest_api.md

library(rjson)
library(RCurl)

urls <- character()
cursor <- "*"
n_articles <- 1000

while(n_articles == 1000){
	search <- "http://api.crossref.org/prefixes/10.1101/works?rows=1000&filter=from-pub-date:2013-11&cursor="

	search_cursor <- paste0(search, cursor)


	page <- fromJSON(getURL(search_cursor), unexpected.escape="keep")

	if(page$status == "ok"){
	cursor <- page$message["next-cursor"]

	articles <- page$message[["items"]]
	n_articles <- length(articles)

	urls <- c(urls, unlist(sapply(articles, '[[', 'URL')))
	print(length(urls))

	} else {
		n_articles <- 0;
	}
}

biorxiv_urls <- urls[grepl("10.1101\\/\\d{6}", urls)]
write(biorxiv_urls, "data/biorxiv_doi_urls.tsv")
