LaTeX Templates for ICIP 2015

Files:
- spconf.sty: LaTeX style file with margin, page layout, font, etc. definitions
- IEEEbib.bst: BiBTeX style file with bibliography style definitions
- main.tex: LaTeX template file
- icip_paper.pdf: PDF generated from the template file
- refs.bib: example file of bibliographic references
- Figures/{image1.eps, image2.eps, image3.eps}: example image files
- Makefile: provides for automatic LaTeX compilation and PDF generation

It is recommended to use the included Makefile to produce the PDF document to
submit to the conference:

  - "make": runs LaTeX and BiBTeX to produce the file icip_paper.dvi.
            Multiple runs are conducted as needed to resolve cross references.
  - "make pdf": produces a format-compliant PDF, icip_paper.pdf, for
                submission. dvips and ps2pdf are used to completely embed and
                subset all fonts.

The Makefile should work on any modern Unix system with dvips and ps2pdf
installed. Windows users will either need to compile by hand or install
Cygwin (http://cygwin.com/).
