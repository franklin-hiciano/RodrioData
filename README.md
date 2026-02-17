# RodrioData

Helps get Bioinformatics datasets quickly (Aspera, Globus, etc.).

# Datasets

## Description

These are index files containing links and metadata for all the files in each dataset. Note that some samples have multiple files. [TODO] To solve this, for each index file we will add a column that serves as the unique identifier for the file. This is what goes into the `--sample` flag.

## Datasets

### Available datasets
The following datasets are available to download:
| Dataset | Type | Database | Notes | Status |
|---|---|---|---|---|
| 1000G_2504_high_coverage | Short reads | IGSR |  | Not implemented |
| 1KG_ONT_VIENNA | SV analysis | IGSR | | Not implemented |
| Platinum Pedigree Consortium | | S3 |  | Not implemented |
| Simons Genome Diversity Project | Sequencing - method? | IGSR | ENA | Not implemented |
| ATAC-seq_LCL_100 | Sequencing - method? | IGSR | ENA | Not implemented |
| 2023_OLR_NATCOMM | AIRR-seq, PacBio Hi-fi long reads | SRA | | Not implemented |
| 2026-Light_EE_NatComm | AIRR-seq, PacBio Hi-fi long reads | SRA | | Not implemneted |
| Human Genome Diversity Project | Illumina short reads | IGSR | | Not implemented |


### Downloading datasets
The following download methods are supported by each database:
| Database | Transfer solution |
|---|---|
| IGSR | Globus |
| SRA | Globus |
| S3 | S3 |

### Notes on the datasets
1. The combination of both 1KG_ONT_VIENNA (Structural variants) and ATAC-seq_LCL_100 (3D chromatin data) allow us to perform studies on chromatin structure and genetic variants at the same time. 

## Notes on European Nucleotide Archive (ENA) datasets

The table containing download links on the ENA website may be missing some cells (no value, N/A, etc.), and unfortunately if you download the table, then you might not have links for the samples you want. We suspect it might be because the website pre-filters the data shown. 

In any case, we include the original file through `curl` using the columns we want. The columns for each `.tsv` file change depending on what type of dataset is enumerated [here](https://ena-docs.readthedocs.io/en/latest/retrieval/programmatic-access/advanced-search.html#id9), e.g. `read_run` or `analysis_study`. We provide a `.txt` file alongside each ENA study's dataset detailing each column's meaning, [like this](study_PRJEB9586/readFields_PRJEB9586.tsv). 

The following datasets are affected.

## ENA datasets

1. Simons Genome Diversity Project
2. ATAC-seq_LCL_100

# Usage
## Batch options

Each batch's size limit, in bytes. The script will output an estimate of how many batches you probably need. You can decide this value based on how much space you want the dataset to occupy in `scratch` at any given moment. 
```
--batch_size
```

The number of batches. The script will output an estimate of how big each batch will be. 
```
--n_batches
```

Downloads the full dataset.
```
--full_dataset
```

## Retrieval options

```
--download
```
Returns just the index file for the dataset you want.
```
--get_index
```


# Planning
## General idea:
The script has datasets in 
```
script.py
datasets/
         1KG.txt
          HGSV.txt
          PUBMED_ID.txt
```

It's modular, so you can add a dataset at any time.
```
python script.py download --dataset 1KG --scratch_dir --run_globus
python script.py download --dataset HGSV --scratch_dir --run_globus
python script.py download --dataset ONT_VIENNA --scratch_dir --run_globus
python script.py download --dataset PUBMED_ID --scratch_dir --run_globus
python script.py download --dataset <Future dataset> --scratch_dir --run_globus
```

Script knows dataset locations on the web. Either downloads in batches (if in scratch) or otherwise providing necessary information to download it on their own.



