# Simons Genome Diversity Project

This is dataset information for the Simons Genome Diversity Project.

TODO: Include information about how the script stores and gets data once the functionality is done. 

[ERP010710](https://www.ebi.ac.uk/ena/browser/view/ERP010710)

[PRJEB9586](https://www.ebi.ac.uk/ena/browser/view/PRJEB9586)

Note, when you download the .tsv file (see image below), if for some reason it is missing data, run the below with your preferred columns, which you can find information on in [readFields.tsv](RodrioData/datasets/simons_diversity_genome_project/readFields.tsv). Examples include `fastq_ftp`, `fastq_md5`, `sra_ftp`, `fastq_md5`, `bam_ftp`, etc.
```
curl "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJEB9586&result=read_run&fields=run_accession,fastq_ftp,fastq_md5,fastq_bytes" > PRJEB9586_metadata.tsv
```

[Example in this image]((https://www.ebi.ac.uk/ena/browser/view/PRJEB9586)
<img width="712" height="198" alt="image" src="https://github.com/user-attachments/assets/6496e178-74ce-445b-ae96-b299b30a9e47" />

