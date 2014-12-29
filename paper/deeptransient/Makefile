all:
	pdflatex main
	bibtex main
	pdflatex main
	pdflatex main

spell:
	aspell -ttex -c main.tex

clean:
	@ rm -f *.aux *.bak *.bbl *.blg *.brf *lbbl *lblg *.log *.out *.pdf *.toc main.pdf
