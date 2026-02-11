#!/bin/bash
set -e -x
set -euo pipefail

SCRIPT_DIR=$(dirname "$(realpath "$0")")


function download_with_globus {
        batch_file="$1"
	module load python

        EMBL_EBI_ENDPOINT=47772002-3e5b-4fd3-b97c-18cee38d6df2   # EMBL-EBI Public Data
        MINERVA_ARION_ENDPOINT=6621ca70-103f-4670-a5a7-a7d74d7efbb7

        globus transfer ${EMBL_EBI_ENDPOINT} ${MINERVA_ARION_ENDPOINT} --label "HGSVC TSV transfer 0001" --batch  "${batch_file}" --verify-checksum --sync-level checksum
	
}

function download_with_aspera {
	fofn="$1"
	module load aspera-connect

	xargs -n1 -I{} /hpc/packages/minerva-centos7/aspera-connect/4.2.4/aspera/bin/ascp \
		-i /hpc/packages/minerva-centos7/aspera-connect/3.9.6/etc/asperaweb_id_dsa.openssh \
		-P33001 -O33001 -v -L- \
		'era-fasp@fasp.sra.ebi.ac.uk:{}' \
		'/sc/arion/scratch/hiciaf01/projects/imputation/data/2025-10-07_1KG_short_long'

}

function download_ENA_study_index_file() {
	local study="${1}"
	local result_data_type="${2}"
	local out_dir="${3}"

	local fields=""

	case "${result_data_type}" in
		"read_run")
			fields="run_accession,study_accession,sample_accession,experiment_accession,tax_id,scientific_name,library_layout,library_strategy,library_source,library_selection,instrument_platform,instrument_model,read_count,base_count,cell_type,tissue_type,disease,dev_stage,host,host_sex,age,experimental_factor,first_public,fastq_ftp,fastq_md5,fastq_bytes,fastq_aspera,submitted_ftp,submitted_md5,submitted_bytes,submitted_aspera,sra_ftp,sra_md5,sra_bytes,sra_aspera,bam_ftp,bam_md5,bam_bytes,bam_aspera"
			;;
		"analysis")
			fields="analysis_accession,study_accession,sample_accession,experiment_accession,tax_id,scientific_name,analysis_type,reference_genome,pipeline_name,pipeline_version,cell_type,tissue_type,disease,dev_stage,host,host_sex,age,experimental_factor,first_public,submitted_ftp,submitted_md5,submitted_bytes,submitted_aspera,generated_ftp,generated_md5,generated_bytes,generated_aspera"
			;;
		*)
			echo "[ERROR] No type result data type provided."; exit 1
			;;
	esac
	
	
	mkdir -p "${out_dir}/study_${study}/"
        curl "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${study}&result=${result_data_type}&fields=${fields}" -o "${out_dir}/study_${study}/study_${study}.index"
        curl "https://www.ebi.ac.uk/ena/portal/api/returnFields?result=${result_data_type}" -o "${out_dir}/study_${study}/schema_of_ENA_result_data_type_named_-${result_data_type}-.txt" # Downloads schema
}

function simons_genome_diversity_project {
	download_ENA_study_index_file ERP010710 analysis "${SCRIPT_DIR}/simons_genome_diversity_project/"
	download_ENA_study_index_file PRJEB9586 read_run "${SCRIPT_DIR}/simons_genome_diversity_project/"
}


# TODO: test these on Minerva. These functions just to show where the files are from.
simons_genome_diversity_project


exit 0
if [ -f "$2" ]; then
    if [ "$1" = "--with_globus" ]; then
        download_with_globus "$2"
    elif [ "$1" = "--with_aspera" ]; then
        download_with_aspera "$2"
    else
        echo "Error: Unknown transfer method '$1'"
        exit 1
    fi
else
    echo "Error: File '$2' not found."
    exit 1
fi
