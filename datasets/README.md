# Datasets

1.  1000G_2504_high_coverage 
2.  1KG_ONT_VIENNA
3.  Platinum Pedigree Consortium
4.  Simons Genome Diversity Project
5.  ATAC-seq_LCL_100

# Notes
1. 1KG_ONT_VIENNA (WGS) and ATAC-seq_LCL_100 (3D chromatin data) share the same samples, meaning they can both be used for analyses on the same person 

# Notes on European Nucleotide Archive (ENA) datasets

The table containing download links on the ENA website may be missing some cells (no value, N/A, etc.), and unfortunately if you download the table, then you might not have links for the samples you want. We suspect it might be because the website pre-filters the data shown. 

In any case, we include the original file through `curl` using the columns we want. The columns for each `.tsv` file change depending on what type of dataset is enumerated [here](https://ena-docs.readthedocs.io/en/latest/retrieval/programmatic-access/advanced-search.html#id9), e.g. `read_run` or `analysis_study`. We provide a `.txt` file alongside each ENA study's dataset detailing each column's meaning, [like this](study_PRJEB9586/readFields_PRJEB9586.tsv). 
