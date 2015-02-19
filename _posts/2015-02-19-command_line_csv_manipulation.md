---
title: Command-Line CSV Manipulation
---

I thought I would write a short post describing some common operations you can do with simple CSV files on the command line, using only POSIX utilities which should be available on every *nix operating system (Mac OS X, Linux, etc.).

For more robust operations, see [csvkit](http://csvkit.readthedocs.org/) or [csvfix](https://code.google.com/p/csvfix/).

## Filter CSV Columns

    cut -d, -fCOLUMNS

* `-d,` tells `cut` to use comma as the field separator
* `-fCOLUMNS` (e.g. `-f2,4`) tells `cut` which fields you want output. Field indexing starts at 1.

## Sort CSV By Column

    sort -t, -kCOLUMN,COLUMN [-kCOLUMN,COLUMN]

* `-t,` tells `sort` to use comma as the field separator
* `-kCOLUMN,COLUMN` (e.g. `-k4,4`) arguments give `sort` an ordered list of fields to sort by. Field indexing starts at 1.
* use `-g` to sort by numeric rather than string (alphabetic) value
* use `-r` to reverse sort

[See examples here](http://www.theunixschool.com/2012/08/linux-sort-command-examples.html).

## Set operations on CSVs

Note that these operations expect lexically sorted input. If your files aren't sorted, you can achieve this by [process substitution](http://tldp.org/LDP/abs/html/process-sub.html), e.g. `comm -12 <(sort < A.csv) <(sort < B.csv)`. You can then sort the output by your desired column(s).

`A.csv`:

    a,b,c
    d,e,f
    g,h,i

`B.csv`:

    g,h,i
    j,k,l
    m,n,o

### Intersection of two CSVs

    comm -12 A.csv B.csv

Output:

    g,h,i

### Complement of two CSVs

    comm -13 A.csv B.csv

Output:

    j,k,l
    m,n,o

    comm -23 A.csv B.csv

Output:

    a,b,c
    d,e,f

### Union of two CSVs

    sort -u A.csv B.csv

Output:

    a,b,c
    d,e,f
    g,h,i
    j,k,l
    m,n,o

### Merge of two CSVs

    sort -m A.csv B.csv

Output:

    a,b,c
    d,e,f
    g,h,i
    g,h,i
    j,k,l
    m,n,o

### Merge CSV columns

    paste -d, A.csv B.csv

Output:

    a,b,c,g,h,i
    d,e,f,j,k,l
    g,h,i,m,n,o

This can also be used to perform a sort of key-based join of two CSV files, assuming they are already sorted by the key you want to join on (that is, each line in each file corresponds to the line you want to join on in the other file).

## CSV to TSV

    tr , "\\t" < FILENAME.csv > FILENAME.tsv

## TSV to CSV
    
    tr "\\t" , < FILENAME.tsv > FILENAME.csv

## Re-order/remove/modify CSV columns

    awk -F, '{print $3 "," $1 ".txt," $2}' A.csv

Output:

    c,a.txt,b
    f,d.txt,e
    i,g.txt,h 
