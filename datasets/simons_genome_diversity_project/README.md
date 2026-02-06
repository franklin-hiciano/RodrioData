# ENA

## Why is this folder structured the way it is?

The table containing download links on the ENA website may be missing some cells (no value, N/A, etc.), and unfortunately if you download the table, then you might not have links for the samples you want. We suspect it might be because the website pre-filters the data shown. In any case, it worked for us to get the original file through `curl` using the columns we want. Additionally, we include the column descriptions for each file. Look at [PRJEB9586's columns](study_PRJEB9586/readFields_PRJEB9586.tsv) for an example.

[This guide](https://ena-docs.readthedocs.io/en/latest/retrieval/programmatic-access/advanced-search.html) teaches how to get the URL of a dataset and information about how to get files that help you understand the columns of your TSV (again, like [PRJEB9586's columns](study_PRJEB9586/readFields_PRJEB9586.tsv)). 


## Studies


### Simons Genome Diversity Project
[ERP010710](https://www.ebi.ac.uk/ena/browser/view/ERP010710)

[PRJEB9586](https://www.ebi.ac.uk/ena/browser/view/PRJEB9586)

### ATAC-seq_LCL_100

[PRJEB28318](https://www.ebi.ac.uk/ena/browser/view/PRJEB28318)


TODO: Include information about how the script stores and gets data once the functionality is done. 


