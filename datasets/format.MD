# Tasks
- [x] Create an index file for each dataset. Include only the columns in the column section below. The column names should be the same across index files.
- [ ] Create a json/tsv file with dataset name, path and download method
- [ ] Create a documention on going from SRR to url

# Columns
1. Sample name
2. Assay type: DNA-seq, ATAC-seq, RNA-seq, Strand-seq, AIRR-seq, FLAIRR
3. Biological source: LCL, PBMCs
4. Technology: Element, PacBio, Oxford Nanopore, Illumina
5. File type: FASTQ, BAM
6. Library: PAIRED, UNPAIRED
7. Processed: Raw, Assembly, Alignment
8. URLs; If there are multiple files, colon seperate them. This should only happen for paired end data. File name should end with _1 or _2.
9. Size of file/md5sum

- Skipping 2023_OLR_NATCOMM for now
- Only use study_PRJEB9586

Adding a dataset:
1. Adding an index file takes 20-40 minutes. To save time, use file processing examples from `src/datasets/setup_datasets.sh`. More often than not there is a similar file that has been standardized, and you can take code and repurpose it for your file.
2. Note: under testing, the file estimate and checksum requirement for index files may be removed in favor of checking the file size before downloading and fetching the checksum from the remote server. This would mean removing the checksum column from the existing index files.
  Potential caveats: something might go wrong while getting the checksum/file size live.
This change is being made because the it spares lots of time creating a bash function to fetch information for each index file that the program might as well do automatically as it runs.
