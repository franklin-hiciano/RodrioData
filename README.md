# RodrioData

Helps get Bioinformatics datasets quickly (Aspera, Globus, etc.). With a focus on raw sequencing data.

# Adding a dataset
This involves two steps:
1. Standardizing the index file
2. Adding it to the `json`

## Standardizing the index file
The program requires each file to be in a `std.index` and contain the following columns:

1. Sample name
2. Assay type: DNA-seq, ATAC-seq, RNA-seq, Strand-seq, AIRR-seq, FLAIRR
3. Biological source: LCL, PBMCs, Saliva
4. Platform: Sequel Ile, NovaSeq 6000, etc.
5. Technology: Element, PacBio, Oxford Nanopore, Illumina
6. File type: FASTQ, BAM
7. Library: PAIRED, UNPAIRED
8. Processed: Raw, Assembly, Alignment
9. URLs; If there are multiple files, colon seperate them. This should only happen for paired end data. File name should end with _1 or _2.

Adding a file takes time, so take inspiration from `src/datasets/setup_datasets.sh` and write your code in there to help the next person. Find the index file most similar to yours, see how it was standardized, and maybe steal some code.

### Making the `url` column
Making the url column is not always straightforward. One common problem is datasets that don't come with URLs, just sample IDs. In this case, figure out how to use the id in a url. Then write a script that loops through ids, makes urls from them, and fills the url column. Finally, add your process to the documentations below.

#### SRA to S3
used in `2026_Light_EE_NatComm`

1. Visit [NCBI](https://www.ncbi.nlm.nih.gov)
2. Search for a random SRR id from the dataset
3. Click on run > data access
4. See how the id fits into the path. In this case, I saw `https://sra-pub-run-odp.s3.amazonaws.com/sra/${ID}/${ID}/${FILE_BASENAME}` so I used this blueprint to [process](https://github.com/franklin-hiciano/RodrioData/blob/b76978ce4f23b960dad1b89ed98da21606a55ec7/src/datasets/setup_datasets.sh#L45) my index file.

#### Documentation 2, and so on

### Writing documentation
`Biological source` and `Platform` can be even harder to make because their information is usually hidden somewhere on the internet (and thus completely unreliable from an LLM), so please cite where you get the information for these two columns when you write the dataset's readme. [Here's](https://github.com/franklin-hiciano/RodrioData/blob/12fa4546c7346ae99f1ff2337ad0ed8069770529/datasets/simons_genome_diversity_project/README.md) an example. 

### Adding your dataset to the `json` file

The program reads dataset metadata from `datasets/datasets.json`. But it's more convenient to copy `datasets/datasets.tsv` into Google Sheets, edit it there, and convert it into `json` like this. 
`.tsv` to `.json`:
```
IN_TSV=../../datasets/datasets.tsv
OUT_JSON=../../datasets/datasets.json
cat "${IN_TSV}" | jq -R -s '
  split("\n") | map(select(length > 0) | split("\t")) | .[0] as $keys 
  | .[1:] as $rows
  # Pass 1: Identify which columns (by index) contain a pipe
  | (reduce range(0; $keys|length) as $i ({}; 
      .[$keys[$i]] = (any($rows[][$i] // ""; contains("|"))))) as $needs_array
  # Pass 2: Reconstruct objects, splitting only where $needs_array is true
  | $rows | map(
      . as $row | 
      reduce range(0; $keys|length) as $i ({}; 
        if $needs_array[$keys[$i]] 
        then .[$keys[$i]] = ($row[$i] | split("|"))
        else .[$keys[$i]] = $row[$i]
        end
      )
    )' > "${OUT_JSON}"
```
`.json` to `.tsv`:
```
IN_JSON=../../datasets/datasets.json
OUT_TSV=../../datasets/datasets.tsv
cat "${IN_JSON}" | jq -R -s '
  split("\n") | map(select(length > 0) | split("\t")) | .[0] as $keys 
  | .[1:] | map(. as $row | reduce range(0; $keys|length) as $i ({}; 
      if ($row[$i] | contains("|")) 
      then .[$keys[$i]] = ($row[$i] | split("|")) 
      else .[$keys[$i]] = $row[$i] 
      end
    ))' > "${OUT_TSV}"
```

### Notes on the datasets
1. The combination of both 1KG_ONT_VIENNA (Structural variants) and ATAC-seq_LCL_100 (3D chromatin data) allow us to perform studies on chromatin structure and genetic variants at the same time. 

## Notes on European Nucleotide Archive (ENA) datasets

Index files for ENA datasets are called `project_XXXXXXXXX.std.index`, and might need a special method of downloading. The table containing download links on the ENA website may be missing some cells (no value, N/A, etc.), and unfortunately if you download the table, then you might not have links for the samples you want. We suspect it might be because the website pre-filters the data shown. 

In any case, we include the original file through `curl` using the columns we want. The columns for each `.tsv` file change depending on what type of dataset is enumerated [here](https://ena-docs.readthedocs.io/en/latest/retrieval/programmatic-access/advanced-search.html#id9), e.g. `read_run` or `analysis_study`. We provide a `.txt` file alongside each ENA study's dataset detailing each column's meaning, [like this](study_PRJEB9586/readFields_PRJEB9586.tsv). 

The following datasets are affected.

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





