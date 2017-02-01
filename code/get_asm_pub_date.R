library(dplyr)

dates <- read.table(file="data/asm_doi_urls.tsv")
dates$V1 <- toupper(gsub("http://dx.doi.org/", "", dates$V1))

cites <- read.csv(file="data/wos_counts/asm_wos.temp")
cites$doi <- toupper(cites$doi)

combined <- inner_join(dates, cites, by=c("V1" = "doi"))[,c("V1", "V2", "times.cited")]
colnames(combined) <- c("doi", "date", "times.cited")

write.table(combined, file="data/wos_counts/asm_wos.csv", sep=',', row.names=F)
