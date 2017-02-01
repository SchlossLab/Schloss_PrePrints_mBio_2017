library(rentrez)

wos <- read.csv(file="data/wos_counts/biorxiv_wos.temp", na.string="N/A")
wos <- wos[!is.na(wos$pmid),]

get_pubdate <- function(id){
	entrez_summary(db="pubmed", id=id)$pubdate
}

dates <- sapply(wos$pmid, get_pubdate)
year  <- gsub("^(20\\d{2}).*",     "\\1", dates)
month <- gsub("^20\\d\\d\\s?(...).*", "\\1", dates)
month <- gsub("20..", "", month)
month[month == ""] <- "Jan"

month_convert <- c(Jan = "01", Feb = "02", Mar = "03", Apr = "04",
									 May = "05", Jun = "06", Jul = "07", Aug = "08",
									 Sep = "09", Oct = "10", Nov = "11", Dec = "12")

month_number <- unname(month_convert[month])
year_month <- paste(year, month_number, sep='-')

write.table(cbind(wos, year_month), file="data/wos_counts/biorxiv_wos.csv", sep=',', row.names=F)
