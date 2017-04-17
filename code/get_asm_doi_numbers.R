#https://github.com/CrossRef/rest-api-doc/blob/master/rest_api.md

library(RJSONIO)
library(RCurl)

urls <- character()
dates <- character()
cursor <- "*"
n_articles <- 1000

while(n_articles == 1000){
	search <- "http://api.crossref.org/prefixes/10.1128/works?rows=1000&filter=from-pub-date:2010-01&cursor="

	search_cursor <- paste0(search, cursor)


	page <- fromJSON(getURL(search_cursor), unexpected.escape="keep")

	if(page$status == "ok"){
		cursor <- page$message["next-cursor"]

		articles <- page$message[["items"]]
		n_articles <- length(articles)

		urls <- c(urls, unlist(sapply(articles, '[[', 'URL')))

		dates <- c(dates, sapply(articles, function(x){
			 					paste(x[["published-print"]][["date-parts"]][[1]][1:2], collapse="-" )}))

	} else {
		n_articles <- 0;
	}
	print(length(urls))
}

dates <- gsub("-(\\d)$", "-0\\1", dates)
dates[dates==""] <- NA

journals <- grepl("10.1128\\/[^\\d.]*\\.\\d+", urls)
journal_urls <- urls[journals]
journal_dates <- dates[journals]

journal_data <- data.frame(journal_urls, journal_dates)

write.table(journal_data, file="data/asm_doi_urls.tsv", row.names=F, col.names=F, quote=F, sep='\t')
