library(RJSONIO)
library(dplyr)
options(stringsAsFactors=FALSE)

aggregate_alt_data <- function(alt_file){
	# print(alt_file)

	article_id <- gsub("data/asm_altmetric/(.*).json", "\\1", alt_file)

	json_file <- readLines(alt_file, warn=F)

	if(json_file != "Not Found"){
		alt_json <- fromJSON(json_file)
		altmetric <- alt_json$score
		altmetric_pct <- alt_json$context$all["pct"]
		altmetric_pct <- ifelse(is.null(altmetric_pct), NA, altmetric_pct)
	} else {
		altmetric <- 0
		altmetric_pct <- 0
	}

	list(article_id=article_id, altmetric=altmetric, altmetric_pct=altmetric_pct)
}

altmetrics_files <- list.files(path="data/asm_altmetric", pattern="*.json", full.names=T)
alt_listed <- lapply(altmetrics_files, aggregate_alt_data)
alt_df <- do.call(rbind.data.frame, alt_listed)

date <-read.table(file="data/asm_doi_urls.tsv", header=F, stringsAsFactors=F)
colnames(date) <- c("article_id", "date")
date$article_id <- gsub("http://dx.doi.org/10.1128/(.*)", "\\1", date$article_id)

summary_df <- left_join(alt_df, date, by="article_id")

write.table(summary_df, "data/asm_altmetric/altmetric_summary.tsv", sep='\t', quote=F, row.names=F)

