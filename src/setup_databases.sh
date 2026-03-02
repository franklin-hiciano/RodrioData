#!/bin/bash
set -e -x
set -euo pipefail

DIR=$(cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT="${DIR%%RodrioData*}/RodrioData"

function download_ENA_study_index_file() {
	local study="${1}"
	local result_data_type="${2}"
	local out_dir="${3}"

	local fields=""

	case "${result_data_type}" in
		"read_run")
			fields="run_accession,study_accession,sample_accession,experiment_accession,sample_title,tax_id,scientific_name,library_layout,library_strategy,library_source,library_selection,instrument_platform,instrument_model,read_count,base_count,cell_type,tissue_type,disease,dev_stage,host,host_sex,age,experimental_factor,first_public,fastq_ftp,fastq_md5,fastq_bytes,fastq_aspera,submitted_ftp,submitted_md5,submitted_bytes,submitted_aspera,sra_ftp,sra_md5,sra_bytes,sra_aspera,bam_ftp,bam_md5,bam_bytes,bam_aspera"
			;;
		"analysis")
			fields="analysis_accession,study_accession,sample_accession,experiment_accession,sample_title,tax_id,scientific_name,analysis_type,reference_genome,pipeline_name,pipeline_version,cell_type,tissue_type,disease,dev_stage,host,host_sex,age,experimental_factor,first_public,submitted_ftp,submitted_md5,submitted_bytes,submitted_aspera,generated_ftp,generated_md5,generated_bytes,generated_aspera"
			;;
		*)
			echo "[ERROR] No type result data type provided."; exit 1
			;;
	esac
	
	
	mkdir -p "${out_dir}/study_${study}/"
        curl "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=${study}&result=${result_data_type}&fields=${fields}" -o "${out_dir}/study_${study}/study_${study}.index"
        curl "https://www.ebi.ac.uk/ena/portal/api/returnFields?result=${result_data_type}" -o "${out_dir}/study_${study}/schema_of_ENA_result_data_type_named_-${result_data_type}-.txt" # Downloads schema
}

function prioritize_fastq_download_links {
    local input_file="$1"

    grep -v '^#' "${input_file}" > "${input_file}.hashtag_removed"

    local fastq_bytes_column_index=$(head -n 1 "${input_file}.hashtag_removed" | awk '{
        for (i = 1; i <= NF; i++) if ($i == "fastq_bytes") print i
    }')

    if [[ ! -f "$(dirname ${input_file})/schema_of_ENA_result_data_type_named_-read_run-.txt" ]] || [[ -z "${fastq_bytes_column_index}" ]]; then
        echo "Paired read_run file not found or fastq_bytes column missing"
        rm "${input_file}.hashtag_removed"
        return 1
    fi

    cut -f"1-${fastq_bytes_column_index}" "${input_file}.hashtag_removed" > "${input_file}.filtered"
    rm "${input_file}.hashtag_removed"
}

function download_high_coverage {
	curl "https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/1000G_2504_high_coverage.sequence.index" -o "${PROJECT_ROOT}/datasets/1000G_high_coverage/1000G_2504_high_coverage.sequence.index"
	curl "https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/1000G_698_related_high_coverage.sequence.index" -o "${PROJECT_ROOT}/datasets/1000G_high_coverage/1000G_698_related_high_coverage.sequence.index.txt"
}

function download_1KG_ONT_VIENNA {
	curl "https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1KG_ONT_VIENNA/1KG_ONT_VIENNA_manifest.tsv" -o "${PROJECT_ROOT}/datasets/1KG_ONT_VIENNA/1KG_ONT_VIENNA_manifest.tsv"
}

function download_simons_genome_diversity_project {
	download_ENA_study_index_file ERP010710 analysis "${PROJECT_ROOT}/datasets/simons_genome_diversity_project/"
	download_ENA_study_index_file PRJEB9586 read_run "${PROJECT_ROOT}/datasets/simons_genome_diversity_project/"
	prioritize_fastq_download_links "${PROJECT_ROOT}/datasets/simons_genome_diversity_project/study_PRJEB9586/study_PRJEB9586.index"
}

function download_ATAC-seq_LCL_100 {
	download_ENA_study_index_file PRJEB28318 analysis "${PROJECT_ROOT}/datasets/ATAC-seq_LCL_100/"
}

function download_human_genome_diversity_project { 
	curl -L "https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGDP/hgdp_wgs.sequence.index" -o "${PROJECT_ROOT}/datasets/human_genome_diversity_project/hgdp_wgs.sequence.index"
}

function download_2023_OLR_NATCOMM {
	curl -L "https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-023-40070-x/MediaObjects/41467_2023_40070_MOESM4_ESM.xlsx" -o "${PROJECT_ROOT}/datasets/2023_OLR_NATCOMM/41467_2023_40070_MOESM4_ESM.xlsx"
	python -c "from bash_utils import utils; utils.xlsx_to_tsv('${PROJECT_ROOT}/datasets/2023_OLR_NATCOMM/41467_2023_40070_MOESM4_ESM.xlsx', output_prefix='${PROJECT_ROOT}/datasets/2023_OLR_NATCOMM/2023_OLR_NATCOMM', sheets_to_extract=['Supplementary Data 1'])"
}

function download_2026_Light_EE_NatComm {
    out_path="${PROJECT_ROOT}/datasets/2026-Light_EE_NatComm/metadata-15346978-processed-ok (2).tsv"
    python -c "from bash_utils import utils; utils.download_from_google_drive('1YdkUEmPeVWY2I7iT7n7bmZSqlzvIcofb', '${out_path}')"
}

# assemblies
HIFIASM_ONT="s3://platinum-pedigree-datasets/assemblies/hifiasm_ont"
VERKKO="s3://platinum-pedigree-datasets/assemblies/hifiasm_ont"

# reads
ELEMENT="s3://platinum-pedigree-datasets/data/element/"
HIFI="s3://platinum-pedigree-datasets/data/hifi/"
ILLUMINA="s3://platinum-pedigree-datasets/data/illumina"
ONT="s3://platinum-pedigree-datasets/data/ont"
STRANDSEQ="s3://platinum-pedigree-datasets/data/strandseq"

function make_rows_for_platinum_pedigree {

}	


function add_metadata_to_assembly_rows {
    printf "%s\t%s\t%s\t%s\n" "primary.id" "data_type" "platform" "url" > "${PROJECT_ROOT}/datasets/platinum_pedigree/assign_assemblies_to_samples.tsv"
    
    tail -n +2 "${PROJECT_ROOT}/datasets/platinum_pedigree/make_index_file_with_basic_sample_information_for_platinum_pedigree.index.tsv" | cut -f7 | while read -r primary_id; do
        awk -v id="${primary_id}" '$0 ~ "assemblies/"id {
            if ($0 ~ "verkko") {
                printf "%s\t%s\t%s\t%s\n", id, "assembly", "verkko", "s3://platinum-pedigree-data/"$0
            } else if ($0 ~ "hifiasm") {
                printf "%s\t%s\t%s\t%s\n", id, "assembly", "hifiasm", "s3://platinum-pedigree-data/"$0
            }
        }' "${PROJECT_ROOT}/datasets/platinum_pedigree/list_all_files_in_platinum_pedigree_dataset_to_understand_its_directory_structure.tsv" >> "${PROJECT_ROOT}/datasets/platinum_pedigree/assign_assemblies_to_samples.tsv"
    done
}

function download_platinum_pedigree {
	curl -L "ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/illumina_platinum_pedigree/illumina_platinum_ped.sequence.index" -o "${PROJECT_ROOT}/datasets/platinum_pedigree/illumina_platinum_ped.sequence.index"
}



function get_assembly_file_paths_for_platinum_pedigree_with_metadata {
	:
}

#end goal right now
function make_index_file_for_platinum_pedigree {
	:
}

# TODO: test these on Minerva. These functions just to show where the files are from.
#download_1000G_high_coverage
#download_simons_genome_diversity_project
#download_ATAC-seq_LCL_100
#download_2023_OLR_NATCOMM ON HOLD WHILE I UNDERSTAND THE DATASET
#download_human_genome_diversity_project
#download_2023_OLR_NATCOMM
#download_2026_Light_EE_NatComm
download_platinum_pedigree
