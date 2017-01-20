library(ggplot2)
library(dplyr)
library(tidyr)

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

data <- read.table(file="data/processed/biorxiv_data_summary.tsv", header=T, stringsAsFactors=F)

counts <- data %>% filter(!is.na(date_first_deposited)) %>%
									mutate(year_quarter = paste(gsub(".*, ", "", date_first_deposited),
				 																			sapply(date_first_deposited, get_quarter))) %>%
									group_by(year_quarter) %>%
									summarize(all_n_pp = n(),
														micro_n_pp = sum(is_microbiology | category =="Microbiology", na.rm=T))

tidied <- gather(counts, key=dataset, value=n_pp, all_n_pp, micro_n_pp)

ggplot(tidied, aes(x=rep(1:nrow(all_data),2), y=n_pp, group=dataset, col=dataset)) +
			geom_rect(aes(xmin=-Inf, xmax=1.5, ymin=-Inf, ymax=Inf), fill="#CCCCCC", color="#CCCCCC") +
			geom_rect(aes(xmin=5.5, xmax=9.5, ymin=-Inf, ymax=Inf), fill="#CCCCCC", color="#CCCCCC") +
			geom_line(size=1.5, lineend="round") +
			labs(x="Year", y="Number of Preprints Posted per Quarter") +
			scale_x_continuous(breaks=c(3.5,7.5,11.5), labels=c("2014", "2015", "2016")) +
			scale_y_continuous(limits=c(0,1500)) +
			scale_color_discrete(breaks=c("all_n_pp", "micro_n_pp"),
													labels=c("All preprints", "Microbiology-affiliated")) +
			theme_classic() +
			theme(legend.position = c(0.23,0.92),
						legend.title = element_blank(),
						legend.background = element_blank()
			) +
			ggsave("figures/Figure1.tiff", width=6, height=4.5, unit="in")
