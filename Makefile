SHELL := /bin/bash

print-%:
	@echo '$*=$($*)'

data/biorxiv_doi_urls.tsv : code/get_biorxiv_doi_numbers.R
	R -e "source('code/get_biorxiv_doi_numbers.R')"

DOI_URLS = $(shell cat data/biorxiv_doi_urls.tsv)
DOI_ARTICLES = $(subst http://dx.doi.org/10.1101/,data/biorxiv/,$(DOI_URLS))

#Will assume that these exist and that if they don't there's a good reason...
#DOI_INFO = $(addsuffix .article-info,$(DOI_ARTICLES))
#DOI_METRICS = $(addsuffix .article-metrics,$(DOI_ARTICLES))

$(DOI_ARTICLES) : data/biorxiv_doi_urls.tsv code/get_biorxiv_pages.sh
	bash code/get_biorxiv_pages.sh $@


data/biorxiv_altmetric/altmetric_summary.tsv : data/biorxiv_doi_urls.tsv code/get_biorxiv_altmetric.sh code/aggregate_biorxiv_altmetric_data.R
	bash code/get_biorxiv_altmetric.sh
	R -e "source('code/aggregate_biorxiv_altmetric_data.R')"


data/biorxiv_disqus/comment_count.tsv : code/get_biorxiv_disqus_data.sh code/aggregate_biorxiv_disqus_data.R
	bash code/get_biorxiv_disqus_data.sh
	R -e "source('code/aggregate_biorxiv_disqus_data.R')"


#this also depends on the DOI files...
.SECONDEXPANSION:
data/processed/biorxiv_data_summary.tsv : $$(DOI_ARTICLES)\
																	code/aggregate_biorxiv_data_sources.R\
																	data/biorxiv_disqus/comment_count.tsv\
																	data/biorxiv_altmetric/altmetric_summary.tsv
	R -e "source('code/aggregate_biorxiv_data_sources.R')"


# pull the citation counts from WOS - need to define user id and password as stated in README
data/wos_counts/asm_wos.csv : data/asm_doi_urls.tsv
	echo "DOI" > data/asm_doi.csv
	cut -f 1 data/asm_doi_urls.tsv | cut -f 4,5 -d / >> data/asm_doi.csv
	python code/wos_amr/lookup_ids.py data/asm_doi.csv data/wos_counts/asm_wos.csv
	rm data/asm_doi.csv


# pull the citation counts from WOS - need to define user id and password as stated in README
data/wos_counts/biorxiv_wos.csv : data/biorxiv_doi_urls.tsv
	echo "DOI" > data/biorxiv_doi.csv
	cut -f 1 data/biorxiv_doi_urls.tsv | cut -f 4,5 -d / >> data/biorxiv_doi.csv
	python code/wos_amr/lookup_ids.py data/biorxiv_doi.csv data/wos_counts/biorxiv_wos.csv
	rm data/biorxiv_doi.csv



##########################################################################################


data/asm_doi_urls.tsv : code/get_asm_doi_numbers.R
	R -e "source('code/get_asm_doi_numbers.R')"


data/asm_altmetric/altmetric_summary.tsv : data/asm_doi_urls.tsv code/get_asm_altmetric.sh  code/aggregate_asm_altmetric_data.R
	bash code/get_asm_altmetric.sh
	R -e "source('code/aggregate_asm_altmetric_data.R')"


##########################################################################################


write.paper : data/processed/biorxiv_data_summary.tsv\
							data/asm_altmetric/altmetric_summary.tsv\
							submission/Schloss_PrePrints_mBio_2017.Rmd
	R -e "render('submission/Schloss_PrePrints_mBio_2017.Rmd', clean=FALSE)"
	mv submission/Schloss_PrePrints_mBio_2017.utf8.md submission/Schloss_PrePrints_mBio_2017.md
	rm submission/Schloss_PrePrints_mBio_2017.knit.md
