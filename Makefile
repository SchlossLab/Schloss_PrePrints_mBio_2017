SUBMISSION_STUB = submission/Schloss_PrePrints_mBio_2017

$(SUBMISSION_STUB).pdf : $(SUBMISSION_STUB).md submission/header.tex
	pandoc -s --include-in-header=submission/header.tex -V geometry:margin=1in -o $@ $<
