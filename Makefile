RSCRIPT = Rscript --no-init-file

all:
	${RSCRIPT} -e "rmarkdown::render('index.Rmd')"
