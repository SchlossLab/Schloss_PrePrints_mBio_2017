library(httr)
library(rvest)

all_files <- list.files('data/dois', full.names=T)
articles <- all_files[grepl("\\d$", all_files)]
metrics <- all_files[grepl("article-metrics$", all_files)]
infos <- all_files[grepl("article-info$", all_files)]

doi <- gsub("data/dois/", "10.1101/", articles)


article_page <- read_html(articles[length(articles)])
metric_page <- read_html(metrics[1])
info_page <- read_html(infos[1])

#authors
authors <- article_page %>%
						html_nodes(".highwire-citation-authors") %>%
						html_text() %>% .[[1]] %>%
						strsplit(", ") %>% unlist

#first_author
first_author <- authors[1]

#corr_author
corr_author <- info_page %>%
								html_nodes(".contributors li") %>%
								.[[grep(">1<", .)]] %>%
								html_nodes(".name") %>%
								html_text()

#affiliation
affiliation <- info_page %>%
								html_nodes("address") %>%
								html_text() %>%
								gsub("[\t\n]", "", .) %>%
								gsub ("^\\s*", "", .)


#n_versions
n_versions <- info_page %>%
										html_nodes(".hw-version-previous-link") %>%
										length() + 1

#date_first_deposited
date_first_deposited <- info_page %>% html_nodes(".publication-history") %>% html_text() %>% .[[2]] %>% gsub("Posted (.*)\\.", "\\1", .)

if(n_versions > 1){
	date_first_deposited <- info_page %>%
														html_nodes(".hw-version-previous-link") %>%
														html_text() %>%
														gsub("Previous version \\((.*) - .*\\)\\.", "\\1", .)
}


#journal_published
journal_published <- article_page %>%
												html_nodes(".pub_jnl i") %>%
												html_text()

if(length(journal_published) != 0){
	journal_published <- journal_published[1]
} else {
	journal_published <- NA
}


#license
license <- article_page %>%
						html_nodes(".license-type a") %>%
						html_text()

if(length(license) == 0){
	license <- "None"
}


#category
category <- article_page %>%
							html_nodes(".highwire-article-collection-term") %>%
							html_text() %>%
							gsub("\n", "", .)

#article_path
article_path <- article_page %>%
									html_nodes(".active a") %>%
									html_attr("href") %>%
									.[[1]]


metric_table <- metric_page %>%
									html_nodes(".highwire-stats") %>%
									html_table() %>%
									.[[1]]

#abstract_downloads
abstract_downloads <- sum(metric_table[,"Abstract"])

#pdf_downloads
pdf_downloads <- sum(metric_table[,"PDF"])
