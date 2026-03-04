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

function download_1000G_high_coverage {
	curl "https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/1000G_2504_high_coverage.sequence.index" -o "${PROJECT_ROOT}/datasets/1000G_high_coverage/1000G_2504_high_coverage.sequence.index"
	curl "https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/1000G_698_related_high_coverage.sequence.index" -o "${PROJECT_ROOT}/datasets/1000G_high_coverage/1000G_698_related_high_coverage.sequence.index.txt"
	python ${PROJECT_ROOT}/src/datasets/IndexFile.py add_new_index_file_to_json \
                --file_path "${PROJECT_ROOT}/datasets/1000G_high_coverage/1000G_2504_high_coverage.sequence.index" \
                --dataset_name "1000G_high_coverage" \
                --sample_identifier_column "SAMPLE_NAME" \
                --url_columns "ENA_FILE_PATH"
	python ${PROJECT_ROOT}/src/datasets/IndexFile.py add_new_index_file_to_json \
                --file_path "${PROJECT_ROOT}/datasets/1000G_high_coverage/1000G_698_related_high_coverage.sequence.index.txt" \
                --dataset_name "1000G_high_coverage" \
                --sample_identifier_column "SAMPLE_NAME" \
                --url_columns "ENA_FILE_PATH"
}

function download_1KG_ONT_VIENNA {
    curl -L "https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1KG_ONT_VIENNA/1KG_ONT_VIENNA_manifest.tsv" -o "${PROJECT_ROOT}/datasets/1KG_ONT_VIENNA/1KG_ONT_VIENNA_manifest.tsv"

    {
        printf "sample_id\ttype\tfile_path\tbytes\tmd5sum\n"
	awk '
        /hg38/ {
            split($0, parts_of_file_path, /hg38\/|\.hg38/); 
            printf "%s\t%s\t%s\t%s\t%s\n", parts_of_file_path[2], "hg38", $1, $2, $3 
        }
        /t2t/ {
            split($0, parts_of_file_path, /t2t\/|\.t2t/); 
            printf "%s\t%s\t%s\t%s\t%s\n", parts_of_file_path[2], "t2t", $1, $2, $3 
        }
        /1KG_ONT_VIENNA\/reference/ {
            printf "%s\t%s\t%s\t%s\t%s\n", "N/A", "reference", $1, $2, $3
        }' "${PROJECT_ROOT}/datasets/1KG_ONT_VIENNA/1KG_ONT_VIENNA_manifest.tsv"
    } > "${PROJECT_ROOT}/tmp.txt"

    mv "${PROJECT_ROOT}/tmp.txt" "${PROJECT_ROOT}/datasets/1KG_ONT_VIENNA/1KG_ONT_VIENNA_manifest.tsv"
    python ${PROJECT_ROOT}/src/datasets/IndexFile.py add_new_index_file_to_json \
                --file_path "${PROJECT_ROOT}/datasets/1KG_ONT_VIENNA/1KG_ONT_VIENNA_manifest.tsv" \
                --dataset_name "1KG_ONT_VIENNA" \
                --sample_identifier_column "sample_id" \
                --url_columns "file_path"
}

function download_simons_genome_diversity_project {
	download_ENA_study_index_file ERP010710 analysis "${PROJECT_ROOT}/datasets/simons_genome_diversity_project/"
	download_ENA_study_index_file PRJEB9586 read_run "${PROJECT_ROOT}/datasets/simons_genome_diversity_project/"
	prioritize_fastq_download_links "${PROJECT_ROOT}/datasets/simons_genome_diversity_project/study_PRJEB9586/study_PRJEB9586.index"
	python ${PROJECT_ROOT}/src/datasets/IndexFile.py add_new_index_file_to_json \
                --file_path "${PROJECT_ROOT}/datasets/simons_genome_diversity_project/study_ERP010710/study_ERP010710.index" \
                --dataset_name "simons_genome_diversity_project" \
                --sample_identifier_column "sample_accession" \
                --url_columns "submitted_ftp" "submitted_aspera" "generated_ftp" "generated_aspera"
	python ${PROJECT_ROOT}/src/datasets/IndexFile.py add_new_index_file_to_json \
                --file_path "${PROJECT_ROOT}/datasets/simons_genome_diversity_project/study_ERP010710/study_ERP010710.index" \
                --dataset_name "simons_genome_diversity_project" \
                --sample_identifier_column "sample_accession" \
                --url_columns "fastq_ftp" 
}

function download_ATAC-seq_LCL_100 {
	download_ENA_study_index_file PRJEB28318 analysis "${PROJECT_ROOT}/datasets/ATAC-seq_LCL_100/"
	python ${PROJECT_ROOT}/src/datasets/IndexFile.py add_new_index_file_to_json \
                --file_path "${PROJECT_ROOT}/datasets/ATAC-seq_LCL_100/study_PRJEB28318/study_PRJEB28318.index" \
                --dataset_name "ATAC-seq_LCL_100" \
                --sample_identifier_column "sample_accession" \
                --url_columns "submitted_ftp" "submitted_aspera" "generated_ftp" "generated_aspera" \
}

function download_human_genome_diversity_project { 
	curl -L "https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGDP/hgdp_wgs.sequence.index" -o "${PROJECT_ROOT}/datasets/human_genome_diversity_project/hgdp_wgs.sequence.index"
	python ${PROJECT_ROOT}/src/datasets/IndexFile.py add_new_index_file_to_json \
                --file_path "${PROJECT_ROOT}/datasets/human_genome_diversity_project/hgdp_wgs.sequence.index" \
                --dataset_name "human_genome_diversity_project" \
                --sample_identifier_column "SAMPLE_NAME" \
                --url_columns "ENA_FILE_PATH" \
		--bytes_column "N/A" \
		--estimated_file_size_in_bytes	
}

function download_2023_OLR_NATCOMM {
	curl -L "https://static-content.springer.com/esm/art%3A10.1038%2Fs41467-023-40070-x/MediaObjects/41467_2023_40070_MOESM4_ESM.xlsx" -o "${PROJECT_ROOT}/datasets/2023_OLR_NATCOMM/41467_2023_40070_MOESM4_ESM.xlsx"
	python ${PROJECT_ROOT}/src/datasets/IndexFile.py excel_to_tsv "${PROJECT_ROOT}/datasets/2023_OLR_NATCOMM/41467_2023_40070_MOESM4_ESM.xlsx" \
		--sheet_name "Supplementary Data 1"
	python ${PROJECT_ROOT}/src/datasets/IndexFile.py add_new_index_file_to_json \
                --file_path "${PROJECT_ROOT}/datasets/2023_OLR_NATCOMM/2023_OLR_NATCOMM_Supplementary_Data_1.tsv" \
                --dataset_name "2023_OLR_NATCOMM" \
                --sample_identifier_column "Sample" \
                --url_columns "AIRR-seq Accession" "Pacific Biosciences Sequencing Data Accession" \
		--bytes_column "N/A"	
}

function download_2026_Light_EE_NatComm {
    out_path="${PROJECT_ROOT}/datasets/2026-Light_EE_NatComm/metadata-15346978-processed-ok (2).tsv"
    python ${PROJECT_ROOT}/src/datasets/IndexFile.py download_from_drive \
	    --drive_id '1YdkUEmPeVWY2I7iT7n7bmZSqlzvIcofb' \
	    --out_path "${PROJECT_ROOT}/datasets/2026-Light_EE_NatComm/metadata-15346978-processed-ok (2).tsv"
    python ${PROJECT_ROOT}/src/datasets/IndexFile.py add_new_index_file_to_json \
                --file_path "${out_path}" \
                --dataset_name "2026_Light_EE_NatComm" \
                --sample_identifier_column "sample_name" \
                --url_columns "filename" \
		--bytes_column "N/A"
}
# ------- Platinum Pedigree has a couple functions --------- 
function make_index_file_with_basic_sample_information_for_platinum_pedigree {
	# told ChatGPT to make a .tsv of this table https://github.com/Platinum-Pedigree-Consortium/Platinum-Pedigree-Datasets?tab=readme-ov-file#sample-meta-data
	# copied it into ../datasets/platinum_pedigree/make_index_file_with_basic_sample_information_for_platinum_pedigree.index.tsv
	:
}

function list_all_files_in_platinum_pedigree {
    module load awscli
    local output="${PROJECT_ROOT}/datasets/platinum_pedigree/list_all_files_in_platinum_pedigree.tsv"
    
    aws s3api list-objects-v2 \
        --bucket platinum-pedigree-data \
        --no-sign-request \
        --region us-west-1 \
        --query 'Contents[].[Size, ETag, Key]' \
        --output text | tr -d '"' > "$output"
}

function make_index_file_for_platinum_pedigree {
    local list_file="${PROJECT_ROOT}/datasets/platinum_pedigree/list_all_files_in_platinum_pedigree.tsv"
    local output_file="${PROJECT_ROOT}/datasets/platinum_pedigree/make_index_file_for_platinum_pedigree.tsv"
    local index_file="${PROJECT_ROOT}/datasets/platinum_pedigree/make_index_file_with_basic_sample_information_for_platinum_pedigree.index.tsv"

    # Header with bytes and checksum columns
    printf "%s\t%s\t%s\t%s\t%s\t%s\n" "primary_id" "data_type" "platform" "bytes" "checksum" "url" > "$output_file"

    tail -n +2 "$index_file" | cut -f2,7 | while read -r id primary_id; do
        
        # --- Loop 1: Sequencing Reads ---
        for platform in "element" "hifi" "illumina" "ont" "strandseq"; do
            awk -v id="${id}" -v p_id="${primary_id}" -v plat="${platform}" '
                $3 ~ "data/"plat && ($3 ~ id || $3 ~ p_id) {
                    printf "%s\t%s\t%s\t%s\t%s\t%s\n", p_id, "sequencing_reads", plat, $1, $2, "s3://platinum-pedigree-data/"$3
                }' "$list_file" >> "$output_file"
        done

        # --- Loop 2: Assemblies ---
        for platform in "hifiasm_ont" "verkko"; do
            awk -v id="${id}" -v p_id="${primary_id}" -v plat="${platform}" '
                $3 ~ "assemblies/" && $3 ~ plat && ($3 ~ id || $3 ~ p_id) {
                    printf "%s\t%s\t%s\t%s\t%s\t%s\n", p_id, "assembly", plat, $1, $2, "s3://platinum-pedigree-data/"$3
                }' "$list_file" >> "$output_file"
        done

    done
    
	 python ${PROJECT_ROOT}/src/datasets/IndexFile.py add_new_index_file_to_json \
                --file_path "${PROJECT_ROOT}/datasets/platinum_pedigree/make_index_file_with_basic_sample_information_for_platinum_pedigree.index.tsv" \
                --dataset_name "platinum_pedigree" \
                --sample_identifier_column "sample_id" \
                --url_columns "url"
}

# TODO: test these on Minerva. These functions just to show where the files are from.
#download_1000G_high_coverage
#download_simons_genome_diversity_project
#download_ATAC-seq_LCL_100
#download_2023_OLR_NATCOMM
#download_human_genome_diversity_project
#download_2026_Light_EE_NatComm
#download_1KG_ONT_VIENNA
#make_index_file_with_basic_sample_information_for_platinum_pedigree 
#list_all_files_in_platinum_pedigree
make_index_file_for_platinum_pedigree
