#!/bin/bash
set -e -x
set -euo pipefail

function readFields_PRJEB9586.tsv {
	curl "https://www.ebi.ac.uk/ena/portal/api/returnFields?dataPortal=ena&format=tsv&result=read_run" -o readFields_PRJEB9586.tsv
}

function PRJEB9586_metadata {
	curl "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJEB9586&result=read_run&fieds=run_accession,study_accession,sample_accession,experiment_accession,tax_id,scientific_name,library_layout,library_strategy,library_source,library_selection,instrument_platform,instrument_model,read_count,base_count,cell_type,tissue_type,disease,dev_stage,host,host_sex,age,experimental_factor,first_public,fastq_ftp,fastq_md5,fastq_bytes,fastq_aspera,submitted_ftp,submitted_md5,submitted_bytes,submitted_aspera,sra_ftp,sra_md5,sra_bytes,sra_aspera,bam_ftp,bam_md5,bam_bytes,bam_aspera" > PRJEB9586_metadata.tsv
}

function readFields_ERP010710 {
	curl "https://www.ebi.ac.uk/ena/portal/api/returnFields?result=analysis" > readFields_ERP010710.tsv
}

function ERP010710_metadata {
	curl "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=ERP010710&result=analysis&fields=analysis_accession,study_accession,sample_accession,experiment_accession,tax_id,scientific_name,analysis_type,reference_genome,pipeline_name,pipeline_version,cell_type,tissue_type,disease,dev_stage,host,host_sex,age,experimental_factor,first_public,submitted_ftp,submitted_md5,submitted_bytes,submitted_aspera,generated_ftp,generated_md5,generated_bytes,generated_aspera" > ERP010710_metadata.tsv
}
# TODO: test these on Minerva. These functions just to show where the files are from.
#readFields_PRJEB9586.tsv
#PRJEB9586_metadata
#readFields_ERP010710
#ERP010710_metadata
