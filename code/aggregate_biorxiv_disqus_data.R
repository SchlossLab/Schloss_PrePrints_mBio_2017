#install.packages("RJSONIO")
library(RJSONIO)
library(dplyr)

parse_response <- function(x){
	if(grepl("biorxiv.org", x$link)){
		paper_id <- gsub(".*/(\\d*\\.?\\d)$", "\\1", x$link)
		n_posts <- x$posts
		return(c(paper_id, n_posts))
	} else {
		return(c(NA, NA))
	}
}

summarize_json <- function(x){
	json_data <- fromJSON(content=x)$response
	t(sapply(json_data, parse_response))
}

count_list <- lapply(list.files("data/biorxiv_disqus", pattern="page_.*", full.names=T), summarize_json)
count_df <- data.frame(do.call(rbind, count_list), stringsAsFactors=F)
colnames(count_df) <- c("article_id", "n_comments")
count_df <- count_df[!is.na(count_df$article_id),]

count_df$n_comments <- as.numeric(count_df$n_comments)

count_df$article_id <- gsub("\\.\\d", "", count_df$article_id)

count_tbl <- count_df %>%
								group_by(article_id) %>%
								summarize(n_comments=sum(n_comments))

count_tbl <- count_tbl[grepl("^\\d{6}$", count_tbl$article_id),]

write.table(count_tbl, file="data/biorxiv_disqus/comment_count.tsv", row.names=F, quote=F, sep='\t')
