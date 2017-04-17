#https://github.com/CrossRef/rest-api-doc/blob/master/rest_api.md

library(RJSONIO)
library(RCurl)

urls <- character()
cursor <- "*"

n_articles <- 1000
counter <- n_articles

while(counter == n_articles){
	search <- paste0("http://api.crossref.org/prefixes/10.1101/works?rows=", n_articles, "&filter=from-pub-date:2013-11&cursor=")

	search_cursor <- paste0(search, cursor)

	page <- getURL(search_cursor)
	json <- fromJSON(page, unexpected.escape="keep")

	if(json$status == "ok"){
		cursor <- json$message["next-cursor"]

		articles <- json$message[["items"]]
		counter <- length(articles)

		urls <- c(urls, unlist(sapply(articles, '[[', 'URL')))

		print(length(urls))

	} else {
		counter <- 0;
	}
	Sys.sleep(0.5)
}

biorxiv_urls <- urls[grepl("10.1101\\/\\d{6}", urls)]
write(biorxiv_urls, "data/biorxiv_doi_urls.tsv")
