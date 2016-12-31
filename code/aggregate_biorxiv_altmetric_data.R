library(rjson)

aggregate_alt_data <- function(alt_file){
	print(alt_file)

	article_id <- gsub("data/biorxiv_altmetric/(.{6}).json", "\\1", alt_file)

	json_file <- readLines(alt_file, warn=F)

	if(json_file != "Not Found"){
		alt_json <- fromJSON(json_file)
		altmetric <- alt_json$score
		altmetric_pct <- alt_json$context$all$pct
	} else {
		altmetric <- NA
		altmetric_pct <- NA
	}

	list(article_id=article_id, altmetric=altmetric, altmetric_pct=altmetric_pct)
}

altmetrics_files <- list.files(path="data/biorxiv_altmetric", pattern="*.json", full.names=T)
alt_listed <- lapply(altmetrics_files, aggregate_alt_data)
alt_df <- do.call(rbind.data.frame, alt_listed)

write.table(alt_df, "data/biorxiv_altmetric/altmetric_summary.tsv", sep='\t', quote=F, row.names=F)



#z <- read.table(file="data/altmetric/altmetric_summary.tsv", header=T,
#					colClasses=c("character", "numeric", "numeric"), stringsAsFactors=F)
