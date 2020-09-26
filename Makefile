all: reading-table.md

_data/books-read.csv: _scripts/goodread2read.rb _data/books-metadata.csv ~/Downloads/goodreads_library_export.csv
	./_scripts/goodread2read.rb ~/Downloads/goodreads_library_export.csv

reading-table.md: _data/books-read.csv
	csvsort -r -c 'Date Read' _data/books-read.csv|csv2md > reading-table.md
