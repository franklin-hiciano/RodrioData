#!/bin/bash
set -e -x
set -euo pipefail

DIR=$(cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT=$(realpath "${DIR%%RodrioData*}RodrioData")
echo "${PROJECT_ROOT}"

function download_1000G_high_coverage() {
	curl "https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/1000G_2504_high_coverage.sequence.index" -o "${PROJECT_ROOT}/datasets/1000G_high_coverage/1000G_2504_high_coverage.sequence.index"
	curl "https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1000G_2504_high_coverage/1000G_698_related_high_coverage.sequence.index" -o "${PROJECT_ROOT}/datasets/1000G_high_coverage/1000G_698_related_high_coverage.sequence.index.txt"
	printf "%s\n" "sample_name" "assay_type" "biological_source" "technology" "platform" "file_type" "library" "processed" "url" | paste -s > "${PROJECT_ROOT}/datasets/1000G_high_coverage/1000G_high_coverage.sequence.std.index"
	(tail -n +25 "${PROJECT_ROOT}/datasets/1000G_high_coverage/1000G_2504_high_coverage.sequence.index"; tail -n +25 "${PROJECT_ROOT}/datasets/1000G_high_coverage/1000G_698_related_high_coverage.sequence.index.txt") | awk -F$'\t' -v OFS='\t' '{print $10, "DNA-seq", "LCL", "Illumina", "NovaSeq 6000", "cram", "paired", "alignment", $1 }' - >> "${PROJECT_ROOT}/datasets/1000G_high_coverage/1000G_high_coverage.sequence.std.index" 
}

function download_1KG_ONT_VIENNA() {
	curl -L "https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/1KG_ONT_VIENNA/1KG_ONT_VIENNA_manifest.tsv" -o "${PROJECT_ROOT}/datasets/1KG_ONT_VIENNA/1KG_ONT_VIENNA_manifest.tsv"
	printf "%s\n" "sample_name" "assay_type" "biological_source" "technology" "platform" "file_type" "library" "processed" "url" | paste -s > "${PROJECT_ROOT}/datasets/1KG_ONT_VIENNA/1KG_ONT_VIENNA_manifest.std.index"
	tail -n +3 "${PROJECT_ROOT}/datasets/1KG_ONT_VIENNA/1KG_ONT_VIENNA_manifest.tsv" | head -n -2 | awk -F$'\t' -v OFS='\t' '{split($1, parts_of_file_path, "[/.]"); url = "ftp://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/" $1; file_type = parts_of_file_path[length(parts_of_file_path)]; print parts_of_file_path[3], "DNA-seq", "LCL", "Oxford Nanopore", "R9.4.1", file_type, "unpaired", "alignment", url }' - >> "${PROJECT_ROOT}/datasets/1KG_ONT_VIENNA/1KG_ONT_VIENNA_manifest.std.index"
}

function download_simons_genome_diversity_project() {
	curl -L "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJEB9586&result=read_run&fields=run_accession,sample_accession,sample_alias,submitted_aspera,submitted_ftp,submitted_bytes" -o "${PROJECT_ROOT}/datasets/simons_genome_diversity_project/study_PRJEB9586.index"
	curl -L "https://static-content.springer.com/esm/art%3A10.1038%2Fnature18964/MediaObjects/41586_2016_BFnature18964_MOESM205_ESM.xlsx" -o "${PROJECT_ROOT}/datasets/simons_genome_diversity_project/41586_2016_BFnature18964_MOESM205_ESM.xlsx"
	python ${PROJECT_ROOT}/src/datasets/Dataset.py excel_to_tsv "${PROJECT_ROOT}/datasets/simons_genome_diversity_project/41586_2016_BFnature18964_MOESM205_ESM.xlsx" \
	--sheet_name "Sheet1"
	printf "%s\n" "sample_name" "assay_type" "biological_source" "technology" "platform" "file_type" "library" "processed" "url" | paste -s > "${PROJECT_ROOT}/datasets/simons_genome_diversity_project/study_PRJEB9586.std.index"
	while IFS=$'\t' read -r sample_alias dna_source; do
		tail -n +2 "${PROJECT_ROOT}/datasets/simons_genome_diversity_project/study_PRJEB9586.index" | awk -v sample="${sample_alias}" -v source="${dna_source}" '$3 == sample {ext = (match($4, /.*\.(bam|fastq|fasta|vcf|gvcf|cram|tbi|fai|bai|crai)(\.|$)/, arr)) ? arr[1] : "NA"; print $2, "DNA-seq", source, "Illumina", "HiSeq 2000", ext, "paired", "raw", $4 }' - | sed 's/Genomic_from_cell_lines/LCL/' | sed 's/Genomic_from_blood/PBMC/' | sed 's/Genomic_from_saliva/Saliva/' - >> "${PROJECT_ROOT}/datasets/simons_genome_diversity_project/study_PRJEB9586.std.index"
	done < <(tail -n +2 "${PROJECT_ROOT}/datasets/simons_genome_diversity_project/41586_2016_BFnature18964_MOESM205_ESM.Sheet1.tsv" | cut -f4,6)
}

function download_ATAC_seq_LCL_100() {
	curl -L "https://www.ebi.ac.uk/ena/portal/api/filereport?accession=PRJEB28318&result=analysis&fields=sample_accession,generated_ftp" -o "${PROJECT_ROOT}/datasets/ATAC-seq_LCL_100/study_PRJEB28318.index"
	printf "%s\n" "sample_name" "assay_type" "biological_source" "technology" "platform" "file_type" "library" "processed" "url" | paste -s > "${PROJECT_ROOT}/datasets/ATAC-seq_LCL_100/study_PRJEB28318.std.index"
	tail -n +2 "${PROJECT_ROOT}/datasets/ATAC-seq_LCL_100/study_PRJEB28318.index" | awk -F$'\t' -v OFS='\t' '{num_links=split($2,file_paths,";"); for(i=1;i<=num_links;i++) {split(file_paths[i], parts, "."); file_type = parts[length(parts)]; print $1,"ATAC-seq","LCL","Illumina","HiSeq 2500",file_type,"paired","alignment",file_paths[i]}}' >> "${PROJECT_ROOT}/datasets/ATAC-seq_LCL_100/study_PRJEB28318.std.index"

}

function download_human_genome_diversity_project() { 
	curl -L "https://ftp.1000genomes.ebi.ac.uk/vol1/ftp/data_collections/HGDP/hgdp_wgs.sequence.index" -o "${PROJECT_ROOT}/datasets/human_genome_diversity_project/hgdp_wgs.sequence.index"
	printf "%s\n" "sample_name" "assay_type" "biological_source" "technology" "platform" "file_type" "library" "processed" "url" | paste -s > "${PROJECT_ROOT}/datasets/human_genome_diversity_project/hgdp_wgs.sequence.std.index" 
	tail -n +25 "${PROJECT_ROOT}/datasets/human_genome_diversity_project/hgdp_wgs.sequence.index" | paste -d '\t' - - | awk -F$'\t' -v OFS='\t' '{urls = $1 ";" $23; print $10, "DNA-seq", "LCL", "Illumina", "HiSeq X", "fastq", "paired", "raw", urls }' - >> "${PROJECT_ROOT}/datasets/human_genome_diversity_project/hgdp_wgs.sequence.std.index"
}

function download_2026_Light_EE_NatComm() {
	python ${PROJECT_ROOT}/src/datasets/Dataset.py download_from_drive \
	    --drive_id '1YdkUEmPeVWY2I7iT7n7bmZSqlzvIcofb' \
	    --out_path "${PROJECT_ROOT}/datasets/2026-Light_EE_NatComm/metadata-15346978-processed-ok (2).tsv"
	printf "%s\n" "sample_name" "assay_type" "biological_source" "technology" "platform" "file_type" "library" "processed" "url" | paste -s > "${PROJECT_ROOT}/datasets/2026-Light_EE_NatComm/2026-Light_EE_NatComm.std.index"
	tail -n +2 "${PROJECT_ROOT}/datasets/2026-Light_EE_NatComm/metadata-15346978-processed-ok (2).tsv" | head -n 193 | awk -F$'\t' -v OFS='\t' '{url = "s3://sra-pub-src-13/" $1 "/" $17 ".1"; ext = (match(url, /.*\.(bam|fastq|fasta|vcf|gvcf|cram|tbi|fai|bai|crai)(\.|$)/, arr)) ? arr[1] : "NA"; print $1, "DNA-seq", "PBMC", "llumina", "NextSeq", ext, "paired", "alignment", url }' >> "${PROJECT_ROOT}/datasets/2026-Light_EE_NatComm/2026-Light_EE_NatComm.std.index"
	tail -n +195 "${PROJECT_ROOT}/datasets/2026-Light_EE_NatComm/metadata-15346978-processed-ok (2).tsv" | awk -F$'\t' -v OFS='\t' '{ext = (match($3, /.*\.(bam|fastq|fasta|vcf|gvcf|cram|tbi|fai|bai|crai)(\.|$)/, arr)) ? arr[1] : "NA"; url = "s3://sra-pub-src-13/" $1 "/" $17 ".1;" "s3://sra-pub-src-13/" $1 "/" $18 ".1"; print $1, "AIRR_seq", "Illumina", "NextSeq", ext, "paired", "raw", url }' >> "${PROJECT_ROOT}/datasets/2026-Light_EE_NatComm/2026-Light_EE_NatComm.std.index"
}

function make_index_file_for_platinum_pedigree() {
    local list_file="${PROJECT_ROOT}/datasets/platinum_pedigree/list_all_files_in_platinum_pedigree.tsv"
    local output_file="${PROJECT_ROOT}/datasets/platinum_pedigree/make_index_file_for_platinum_pedigree.std.index"
    local index_file="${PROJECT_ROOT}/datasets/platinum_pedigree/make_index_file_with_basic_sample_information_for_platinum_pedigree.index.tsv"
    printf "%s\n" "sample_name" "assay_type" "biological_source" "technology" "platform" "file_type" "library" "processed" "url" | paste -s > "$output_file"
    tail -n +2 "$index_file" | cut -f2,7 | while read -r id primary_id; do
        for platform in "element" "hifi" "illumina" "ont" "strandseq"; do
            awk -v id="${id}" -v p_id="${primary_id}" -v plat="${platform}" 'BEGIN { FS="\t"; OFS="\t" } $3 ~ "data/"plat && ($3 ~ id || $3 ~ p_id) { bio = ($3 ~ /ont/) ? "LCL" : "PBMC"; tech = (match($3, /(element|hifi|illumina|ont|strandseq)/, arr)) ? arr[1] : "NA"; ext = (match($3, /.*\.(bam|fastq|fasta|vcf|gvcf|cram|tbi|fai|bai|crai)(\.|$)/, arr)) ? arr[1] : "NA"; proc = ($3 ~ /mapped/) ? "alignment" : "raw"; print p_id, "DNA-seq", bio, tech, ext, "unpaired", proc, $3 }' "$list_file" >> "$output_file"
        done
        awk -v id="${id}" -v p_id="${primary_id}" 'BEGIN { FS="\t"; OFS="\t" } $3 ~ "assemblies/" && ($3 ~ id || $3 ~ p_id) { print p_id, "NA", "NA", "NA", "fasta", "NA", "assembly", $3 }' "$list_file" >> "$output_file"
    done
}
# --- Execution ---
download_1000G_high_coverage
download_1KG_ONT_VIENNA
download_simons_genome_diversity_project
download_ATAC_seq_LCL_100
download_human_genome_diversity_project
download_2026_Light_EE_NatComm
make_index_file_for_platinum_pedigree


