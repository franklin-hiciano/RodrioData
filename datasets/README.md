# Index files

## Description

These are index files containing links and metadata for all the files in each dataset. Note that some samples have multiple files. [TODO] To solve this, for each index file we will add a column that serves as the unique identifier for the file. This is what goes into the `--sample` flag.

## Datasets

| Dataset | Type | Methods available | Notes | Status |
|---|---|---|---| --- |
| 1000G_2504_high_coverage | Short reads | Globus | 1000 genomes | Not implemented |
| 1KG_ONT_VIENNA | SV analysis | Globus | 1000 genomes | Not implemented |
| Platinum Pedigree Consortium | | AWS |  | Not implemented |
| Simons Genome Diversity Project | Sequencing - method? | Globus | ENA | Not implemented |
| ATAC-seq_LCL_100 | Sequencing - method? |  | ENA | Not implemented |
| 2023_OLR_NATCOMM | AIRR-seq, PacBio Hi-fi long reads | Globus (SRA) | | Not implemented |
| 2026-Light_EE_NatComm | AIRR-seq, PacBio Hi-fi long reads | Globus (SRA) | | Not implemneted |

Statuses: Not implemented, In progress, Implemented 

### Notes on the datasets
1. The combination of both 1KG_ONT_VIENNA (Structural variants) and ATAC-seq_LCL_100 (3D chromatin data) allow us to perform studies on chromatin structure and genetic variants at the same time. 

## Notes on European Nucleotide Archive (ENA) datasets

The table containing download links on the ENA website may be missing some cells (no value, N/A, etc.), and unfortunately if you download the table, then you might not have links for the samples you want. We suspect it might be because the website pre-filters the data shown. 

In any case, we include the original file through `curl` using the columns we want. The columns for each `.tsv` file change depending on what type of dataset is enumerated [here](https://ena-docs.readthedocs.io/en/latest/retrieval/programmatic-access/advanced-search.html#id9), e.g. `read_run` or `analysis_study`. We provide a `.txt` file alongside each ENA study's dataset detailing each column's meaning, [like this](study_PRJEB9586/readFields_PRJEB9586.tsv). 

The following datasets are affected.

## ENA datasets

1. Simons Genome Diversity Project
2. ATAC-seq_LCL_100
