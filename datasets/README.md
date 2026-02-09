# Index files

## Description

These are index files containing links and metadata for all the files in each dataset. Note that some samples have multiple files. [TODO] To solve this, for each index file we will add a column that serves as the unique identifier for the file. This is what goes into the `sample` argument.

## Datasets

| Header 1 | Header 2 | Header 3 |
|---|---|---|
| 1000G_2504_high_coverage | Row 1, Col 2 | Row 1, Col 3 |
| Row 2, Col 1 | Row 2, Col 2 | Row 2, Col 3 |


1.  1000G_2504_high_coverage 
2.  1KG_ONT_VIENNA
3.  Platinum Pedigree Consortium
4.  Simons Genome Diversity Project
5.  ATAC-seq_LCL_100

### Notes on the datasets
1. The combination of both 1KG_ONT_VIENNA (Structural variants) and ATAC-seq_LCL_100 (3D chromatin data) allow us to perform studies on chromatin structure and genetic variants at the same time. 

## Notes on European Nucleotide Archive (ENA) datasets

The table containing download links on the ENA website may be missing some cells (no value, N/A, etc.), and unfortunately if you download the table, then you might not have links for the samples you want. We suspect it might be because the website pre-filters the data shown. 

In any case, we include the original file through `curl` using the columns we want. The columns for each `.tsv` file change depending on what type of dataset is enumerated [here](https://ena-docs.readthedocs.io/en/latest/retrieval/programmatic-access/advanced-search.html#id9), e.g. `read_run` or `analysis_study`. We provide a `.txt` file alongside each ENA study's dataset detailing each column's meaning, [like this](study_PRJEB9586/readFields_PRJEB9586.tsv). 

The following datasets are affected.

## ENA datasets

1. Simons Genome Diversity Project
2. ATAC-seq_LCL_100
