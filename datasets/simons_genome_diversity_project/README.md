# ENA

## Why is this folder structured the way it is?

The table containing download links on the ENA website may be missing some cells (no value, N/A, etc.), and unfortunately if you download the table, then you might not have links for the samples you want. We suspect it might be because the website pre-filters the data shown. In any case, it worked for us to get the original file through `curl` using the columns we want. Additionally, we include the column descriptions for each file. Look at [PRJEB9586's columns](study_PRJEB9586/readFields_PRJEB9586.tsv) for an example.

[This guide](https://ena-docs.readthedocs.io/en/latest/retrieval/programmatic-access/advanced-search.html) teaches how to get the URL of a dataset and information about how to get files that help you understand the columns of your TSV (again, like [PRJEB9586's columns](study_PRJEB9586/readFields_PRJEB9586.tsv)). 


## Studies


### Simons Genome Diversity Project
https://www.nature.com/articles/nature18964

[ERP010710](https://www.ebi.ac.uk/ena/browser/view/ERP010710)

[PRJEB9586](https://www.ebi.ac.uk/ena/browser/view/PRJEB9586)

### ATAC-seq_LCL_100

[PRJEB28318](https://www.ebi.ac.uk/ena/browser/view/PRJEB28318)


TODO: Include information about how the script stores and gets data once the functionality is done. 

Paper

The most powerful way to study population history and natural selection is to analyze whole genome sequences, which contain all the variation that exists in each individual. To date, genome-wide studies of history and selection have primarily analyzed data from single nucleotide polymorphism (SNP) arrays which are biased by the choice of which SNPs to include. Alternatively they have analyzed sequence data that have been generated as part of medical genetic studies from populations with large census sizes, and thus do not capture the full scope of human genetic variation. Here we supply high quality genome sequences (~40x average) from 301 individuals from 146 worldwide populations. All samples were sequenced using an identical protocol at the same facility (Illumina Ltd.). We modified standard pipelines to eliminate biases that might confound population genetic studies, to produce a unique alignment and genotype dataset.

# Links:
