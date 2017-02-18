library(ggplot2)
library(dplyr)
library(tidyr)
library(cowplot)
library(sportcolors)

get_quarter <- function(date){

	month <- gsub("(.*) \\d{1,2}, \\d{4}", "\\1", date)

	quarter <- NA
	if(month %in% c("January", "February", "March")){
		quarter <- 1
	} else if(month %in% c("April", "May", "June")){
			quarter <- 2
	} else if(month %in% c("July", "August", "September")){
			quarter <- 3
	} else if(month %in% c("October", "November", "December")){
			quarter <- 4
	}

	return(quarter)
}

my_theme <- theme_classic() +
							theme(legend.title = element_blank(),
										legend.background = element_blank(),
										legend.text = element_text(size=6),
										legend.key.size = unit(0.5, "lines"),
										axis.title = element_text(size=8),
										axis.text = element_text(size=6)
							)

biorxiv <- read.table(file="data/processed/biorxiv_data_summary.tsv", header=T, stringsAsFactors=F)
biorxiv$journal_published_doi <- tolower(gsub("http://dx.doi.org/", "", biorxiv$journal_published_doi))

counts <- biorxiv %>% filter(!is.na(date_first_deposited)) %>%
									mutate(year_quarter = paste(gsub(".*, ", "", date_first_deposited),
				 																			sapply(date_first_deposited, get_quarter))) %>%
									group_by(year_quarter) %>%
									summarize(all_n_pp = n(),
														micro_n_pp = sum(is_microbiology | category =="Microbiology", na.rm=T))

tidied <- gather(counts, key=dataset, value=n_pp, all_n_pp, micro_n_pp)

time_course <- ggplot(tidied,
											aes(x=rep(1:length(unique(tidied$year_quarter)),2),
													y=n_pp,
													group=dataset,
													col=dataset)
										) +
			geom_rect(aes(xmin=-Inf, xmax=1.5, ymin=-Inf, ymax=Inf), fill="#CCCCCC", color="#CCCCCC") +
			geom_rect(aes(xmin=5.5, xmax=9.5, ymin=-Inf, ymax=Inf), fill="#CCCCCC", color="#CCCCCC") +
			geom_line(lineend="round") +
			labs(x="Year", y="Number of Preprints\nPosted per Quarter") +
			scale_x_continuous(breaks=c(3.5,7.5,11.5), labels=c("2014", "2015", "2016")) +
			scale_y_continuous(limits=c(0,1500)) +
			scale_color_manual(breaks=c("all_n_pp", "micro_n_pp"),
													labels=c("All preprints", "Microbiology-affiliated"),
													values=c("#002c5a", "#ffcb0b"), name=NULL)+
			my_theme +
			theme(legend.position = c(0.23,0.92), axis.ticks.x=element_blank())


################################################################################################


asm_altmetric <- read.table(file= 'data/asm_altmetric/altmetric_summary.tsv', header=T)
asm_altmetric$date <- gsub("(\\d\\d\\d\\d)-.*", "\\1", asm_altmetric$date)
asm_post_2013 <- asm_altmetric[asm_altmetric$date >= 2013,]
mbio_altmetric <- asm_post_2013[grepl("mbio", asm_post_2013$article_id), "altmetric"]

micro_affiliated <- biorxiv$is_microbiology | biorxiv$category == "Microbiology"
biorxiv_altmetric <- biorxiv[micro_affiliated, 'altmetric_score']

source <- c(rep("biorxiv", length(biorxiv_altmetric)),
						rep("mbio", length(mbio_altmetric)))
altmetric <- c(biorxiv_altmetric, mbio_altmetric)

source_altmetric <- data.frame(source, altmetric)
source_altmetric$source <- factor(source_altmetric$source, levels=c("mbio", "biorxiv"))

median_alt <- source_altmetric %>%
											group_by(source) %>%
											summarize(median=median(altmetric, na.rm=T),
																n=n()
											)

j <- c(biorxiv="bioRxiv", mbio="mBio")
n <- unlist(c(median_alt[median_alt$source=="biorxiv", "n"], median_alt[median_alt$source=="mbio", "n"]))

plot_labels <- lapply(1:2, function(i) {bquote(italic(.(j[i]))*" (N="*.(n[i])*")")})

altmetric_plot <- source_altmetric %>% #filter(source == "biorxiv") %>%
											ggplot(aes(x=altmetric, fill=source)) +
											geom_histogram(binwidth=1, alpha=0.5, position="identity") +
											geom_vline(data=median_alt, aes(xintercept=median, color=source), size=0.5, show.legend=FALSE, alpha=0.5) +
											scale_y_continuous(expand = c(0.02, 0), limits=c(0,200)) +
											scale_x_continuous(expand = c(0.02, 0), limits=c(0,100)) +
											labs(x="Altmetric Impact Score", y="Number of\nPapers or Preprints") +
											scale_fill_manual(breaks=names(j), labels=plot_labels, values=paste0("#", team_colors("Chicago Cubs")), name=NULL)+
											scale_color_manual(breaks=names(j), labels=plot_labels, values=paste0("#", team_colors("Chicago Cubs")), name=NULL)+
											my_theme +
											theme(legend.position = c(0.8,0.9))

################################################################################################

biorxiv_cited <- read.csv("data/wos_counts/biorxiv_wos.csv", stringsAsFactors=F)
biorxiv_cited$doi <- tolower(biorxiv_cited$doi)
biorxiv_cited <- inner_join(biorxiv_cited, biorxiv, by=c("doi"="journal_published_doi"))
biorxiv_cited_affiliated <- biorxiv_cited[biorxiv_cited$is_microbiology | biorxiv_cited$category == "Microbiology",]
cites_2015 <- grep("201[45]", biorxiv_cited_affiliated$year_month)
biorxiv_cited_affiliated_2015 <-  biorxiv_cited_affiliated[cites_2015, "times.cited"]

asm_cited <- read.csv("data/wos_counts/asm_wos.csv", stringsAsFactors=F)
mbio_cited <- asm_cited[grepl("MBIO", asm_cited$doi),]
mbio_2015 <- grep("201[45]", mbio_cited$date)
mbio_cited_2015 <- mbio_cited[mbio_2015, "times.cited"]

source <- c(rep("biorxiv", length(biorxiv_cited_affiliated_2015)),
						rep("mbio", length(mbio_cited_2015)))
citations <- c(biorxiv_cited_affiliated_2015, mbio_cited_2015)
source_citations <- data.frame(source, citations, stringsAsFactors=T)
source_citations$source <- factor(source_citations$source, levels=c("mbio", "biorxiv"))

median_cites <- source_citations %>%
										group_by(source) %>%
										summarize(median=median(citations),
															n=n()
										)

j <- c(biorxiv="bioRxiv", mbio="mBio")
n <- unlist(c(median_cites[median_cites$source=="biorxiv", "n"], median_cites[median_cites$source=="mbio", "n"]))

plot_labels <- lapply(1:2, function(i) {bquote(italic(.(j[i]))*" (N="*.(n[i])*")")})

citation_plot <- source_citations %>%
											ggplot(aes(x=citations, fill=source)) +
											geom_histogram(binwidth=1, alpha=0.5, position="identity") +
											geom_vline(data=median_cites, aes(xintercept=median, color=source), size=0.5, show.legend=FALSE, alpha=0.5) +
											scale_y_continuous(expand = c(0.02, 0), limits=c(0,100)) +
											scale_x_continuous(expand = c(0.02, 0), limits=c(0,80)) +
											scale_fill_manual(breaks=names(j), labels=plot_labels, values=paste0("#", team_colors("Chicago Cubs")), name=NULL)+
											scale_color_manual(breaks=names(j), labels=plot_labels, values=paste0("#", team_colors("Chicago Cubs")), name=NULL)+
											labs(x="Number of Citations", y="Number of Papers\nPublished in 2014/2015") +
 											my_theme +
 											theme(legend.position = c(0.8,0.9))

################################################################################################

ggdraw() +
	draw_plot(time_course +
				theme(axis.title.y = element_text(margin = margin(r=1))),
				x=0,y=0.66,width=1,height=0.33) +
	draw_plot(altmetric_plot +
				theme(axis.title.y = element_text(margin = margin(r=5))),
				x=0,y=0.33,1,0.33) +
	draw_plot(citation_plot +
				theme(axis.title.y = element_text(margin = margin(r=7))),
				x=0,y=0.0,1,0.33) +
	draw_plot_label(c("A", "B", "C"), x=c(0,0,0), y=c(1.00,0.66,0.33), size=12) +
	ggsave('figures/figure1.eps', width=8.4, height=14, units="cm") +
	ggsave('figures/figure1.png', width=8.4, height=14, units="cm")
