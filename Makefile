SHELL := /bin/bash

print-%:
	@echo '$*=$($*)'

data/doi_urls.txt : code/get_doi_numbers.R
	R -e "source('code/get_doi_numbers.R')"

DOI_URLS = $(shell cat data/doi_urls.txt)
DOI_ARTICLES = $(subst http://dx.doi.org/10.1101/,data/biorxiv/,$(DOI_URLS))

#Will assume that these exist and that if they don't there's a good reason...
#DOI_INFO = $(addsuffix .article-info,$(DOI_ARTICLES))
#DOI_METRICS = $(addsuffix .article-metrics,$(DOI_ARTICLES))

$(DOI_ARTICLES) : data/doi_urls.txt code/get_pp_pages.sh
	bash code/get_pp_pages.sh $@


data/altmetric/altmetric_summary.tsv : data/doi_urls.txt code/get_altmetric.sh code/aggregate_altmetric_data.R
	bash code/get_altmetric.sh
	R -e "source('code/aggregate_altmetric_data.R')"


data/disqus/comment_count.tsv : code/get_disqus_data.sh code/aggregate_disqus_data.R
	bash code/get_disqus_data.sh
	R -e "source('code/aggregate_disqus_data.R')"


#this also depends on the DOI files...
.SECONDEXPANSION:
data/processed/biorxiv_data_summary.json : $$(DOI_ARTICLES)\
																	code/aggregate_data_sources.R\
																	data/disqus/comment_count.tsv\
																	data/altmetric/altmetric_summary.tsv
	R -e "source('code/aggregate_data_sources.R')"


write.paper :
	R -e "render('submission/Schloss_PrePrints_mBio_2017.Rmd', clean=FALSE)"
	mv submission/Schloss_PrePrints_mBio_2017.utf8.md submission/Schloss_PrePrints_mBio_2017.md
	rm submission/Schloss_PrePrints_mBio_2017.knit.md
