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
data/wos_counts/biorxiv_wos.csv : data/processed/biorxiv_data_summary.tsv code/get_biorxiv_pub_date.R
	echo "DOI" > data/biorxiv_doi.csv
	grep "dx.doi.org" data/processed/biorxiv_data_summary.tsv | cut -f 9 | sed -e "s=\"http://dx.doi.org/\(.*\)\"=\1=" | iconv -c -f utf-8 -t ascii >> data/biorxiv_doi.csv
	python code/wos-amr/lookup_ids.py data/biorxiv_doi.csv data/wos_counts/biorxiv_wos.temp
	R -e "source('code/get_biorxiv_pub_date.R')"
	rm data/biorxiv_doi.csv data/wos_counts/biorxiv_wos.temp


##########################################################################################


data/asm_doi_urls.tsv : code/get_asm_doi_numbers.R
	R -e "source('code/get_asm_doi_numbers.R')"


data/asm_altmetric/altmetric_summary.tsv : data/asm_doi_urls.tsv code/get_asm_altmetric.sh  code/aggregate_asm_altmetric_data.R
	bash code/get_asm_altmetric.sh
	R -e "source('code/aggregate_asm_altmetric_data.R')"


# pull the citation counts from WOS - need to define user id and password as stated in README
data/wos_counts/asm_wos.csv : data/asm_doi_urls.tsv code/get_asm_pub_date.R
	echo "DOI" > data/asm_doi.csv
	cut -f 1 data/asm_doi_urls.tsv | cut -f 4,5 -d / >> data/asm_doi.csv
	python code/wos-amr/lookup_ids.py data/asm_doi.csv data/wos_counts/asm_wos.temp
	R -e "source('code/get_asm_pub_date.R')"
	rm data/asm_doi.csv data/wos_counts/asm_wos.temp


##########################################################################################

figures/figure1.% : data/processed/biorxiv_data_summary.tsv\
							data/asm_altmetric/altmetric_summary.tsv\
							data/wos_counts/asm_wos.csv\
							data/wos_counts/biorxiv_wos.csv\
							code/build_figure1.R
	R -e "source('code/build_figure1.R')"


write.paper : data/processed/biorxiv_data_summary.tsv\
							data/asm_altmetric/altmetric_summary.tsv\
							data/processed/country_lookup.tsv\
							data/wos_counts/asm_wos.csv\
							data/wos_counts/biorxiv_wos.csv\
							figures/figure1.png\
							figures/figure1.pdf\
							submission/Schloss_PrePrints_mBio_2017.Rmd
	R -e "render('submission/Schloss_PrePrints_mBio_2017.Rmd', clean=FALSE)"
	mv submission/Schloss_PrePrints_mBio_2017.utf8.md submission/Schloss_PrePrints_mBio_2017.md
	rm submission/Schloss_PrePrints_mBio_2017.knit.md
