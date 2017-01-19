library(httr)
library(rvest)
library(dplyr)

disqus_count <- read.table(file="data/biorxiv_disqus/comment_count.tsv", header=T,
												stringsAsFactors=F, colClasses=c("character", "numeric"))

altmetric_score <- read.table(file="data/biorxiv_altmetric/altmetric_summary.tsv", header=T,
												stringsAsFactors=F, colClasses=c("character", "numeric", "numeric"))


collect_data <- function(base_file){
	print(base_file)

#	base_file <- "data/biorxiv/000026"

	article_file <- base_file
	metric_file <- paste0(base_file,".article-metrics")
	info_file <- paste0(base_file,".article-info")

	article_page <- read_html(article_file)

	#doi
	doi <- gsub("data/biorxiv/", "10.1101/", base_file)

	if(!grepl("This paper is still processing|DOI Not Found", article_page)){

		metric_page <- read_html(metric_file)
		info_page <- read_html(info_file)

		#authors
		authors <- article_page %>%
								html_nodes(".highwire-citation-authors") %>%
								html_text() %>% .[[1]] %>%
								strsplit(", ") %>%
								unlist %>%
								gsub(" View ORCID Profile", "", .)

		#first_author
		first_author <- authors[1]

		#corr_author
		corr_author <- info_page %>%
										html_nodes(".contributor-list li") %>%
										.[[grep("corresp", .)]] %>%
										html_nodes(".name") %>%
										html_text()

		#corr_author_email
		corr_author_email <- info_page %>%
										html_nodes(".corresp .em-addr") %>%
										html_text()

		#affiliation
		affiliation <- info_page %>%
										html_nodes("address") %>%
										html_text() %>%
										gsub("[\t\n]", "", .) %>%
										gsub ("^\\d*", "", .) %>%
										gsub ("^\\s*", "", .)
		if(length(affiliation) != 0){
			affiliation <- affiliation[1]
		} else {
			affiliation <- NA
		}


		#n_versions
		n_versions <- info_page %>%
												html_nodes(".hw-version-previous-link") %>%
												length() + 1

		#date_first_deposited
		date_first_deposited <- info_page %>%
											html_nodes(".publication-history") %>%
											html_text() %>%
											.[[2]] %>%
											gsub("Posted (.*)\\.", "\\1", .)

		if(n_versions > 1){
			date_first_deposited <- info_page %>%
																html_nodes(".hw-version-previous-link") %>%
																html_text() %>%
																gsub("Previous version \\((.*) - .*\\)\\.", "\\1", .) %>%
																.[[1]]
		}

		#journal_published
		journal_published <- article_page %>%
														html_nodes(".pub_jnl i") %>%
														html_text()

		journal_published_doi <- article_page %>%
															html_nodes(".pub_jnl a") %>%
															html_attr("href")

		if(length(journal_published) != 0){
			journal_published <- journal_published[1]
			journal_published_doi <- journal_published_doi[1]
		} else {
			journal_published <- NA
			journal_published_doi <- NA
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
		if(length(category) == 0){
			category <- NA
		} else {
			category <- category[1]
		}

		#is_microbiology
		test_is_microbiology <- function(x){
			pattern <- "yeast|fung|viral|virus|archaea|bacteri|microb|microorganism|pathogen"
			grepl(pattern, x, ignore.case = TRUE)
		}

		abstract <- article_page %>% html_nodes(".section .abstract") %>% html_text() %>% gsub("\n", " ", .)
		title <- article_page %>% html_nodes("#page-title") %>% html_text()
		is_microbiology <- test_is_microbiology(paste(abstract, title))

		#article_path
		article_path <- article_page %>%
											html_nodes(".active a") %>%
											html_attr("href") %>%
											.[[1]]


		#abstract_downloads
		#pdf_downloads
		abstract_downloads <- NA
		pdf_downloads <- NA

		if(!grepl("No statistics are available", metric_page)){
			metric_table <- metric_page %>%
												html_nodes(".highwire-stats") %>%
												html_table() %>%
												.[[1]]

			abstract_downloads <- sum(metric_table[,"Abstract"])
			pdf_downloads <- sum(metric_table[,"PDF"])
		}


		#n_comments
		disqus_data <- disqus_count %>%
										filter(article_id == gsub("data/biorxiv/", "", base_file))

		n_comments <- 0
		if(nrow(disqus_data) != 0){
			n_comments <- disqus_data[,"n_comments"]
		}

		#altmetric_score
		#altmetric_percentile
		altmetric_data <- altmetric_score %>%
										filter(article_id == gsub("data/biorxiv/", "", base_file))

		altmetric_score <- 0
		altmetric_percentile <- 0
		if(nrow(altmetric_data) != 0){
			altmetric_score <- altmetric_data[,"altmetric"]
			altmetric_percentile <- altmetric_data[,"altmetric_pct"]
		}


	} else {
		doi <- doi
		# authors <- NA
		first_author <- NA
		corr_author <- NA
		corr_author_email <- NA
		affiliation <- NA
		n_versions <- NA
		date_first_deposited <- NA
		journal_published <- NA
		journal_published_doi <- NA
		category <- NA
		is_microbiology <- NA
		license <- NA
		abstract_downloads <- NA
		pdf_downloads <- NA
		n_comments <- NA
		altmetric_score <- NA
		altmetric_percentile <- NA
	}

	list(
		doi=doi,
		# authors=authors,
		first_author=first_author,
		corr_author=corr_author,
		corr_author_email=corr_author_email,
		affiliation=affiliation,
		n_versions=n_versions,
		date_first_deposited=date_first_deposited,
		journal_published=journal_published,
		journal_published_doi=journal_published_doi,
		category=category,
		is_microbiology=is_microbiology,
		license = license,
		abstract_downloads=abstract_downloads,
		pdf_downloads=pdf_downloads,
		n_comments=n_comments,
		altmetric_score=altmetric_score,
		altmetric_percentile=altmetric_percentile
	)

}

base_files <- list.files(path='data/biorxiv', pattern="^\\d{6}$", full.names=T)
results_list <- lapply(base_files, collect_data)
results <- do.call(rbind.data.frame, results_list)

write.table(results, "data/processed/biorxiv_data_summary.tsv", quote=T, row.names=F, sep='\t')
