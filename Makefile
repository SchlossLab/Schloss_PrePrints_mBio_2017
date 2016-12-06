write.paper : 
	R -e "render('submission/Schloss_PrePrints_mBio_2017.Rmd', clean=FALSE)"
	mv submission/Schloss_PrePrints_mBio_2017.utf8.md submission/Schloss_PrePrints_mBio_2017.md
	rm submission/Schloss_PrePrints_mBio_2017.knit.md
