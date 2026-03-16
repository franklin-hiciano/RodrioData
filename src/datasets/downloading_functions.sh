#!/bin/bash
set -e -x
set -euo pipefail

# ---------- CURL -------- 
DIR=$(cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT="${DIR%%RodrioData*}/RodrioData"

function CURL_download_one_file {
        remote_path="${1}"
	local_path="${2}"
        curl -L -O "${file}"
}

function CURL_get_size_of_remote_file() {
    curl -sI "$1" | grep -i "Content-Length" | awk '{print $2}' | tr -d '\r'
}

# ---------- GLOBUS ----------- 

EMBL_EBI_ENDPOINT="47772002-3e5b-4fd3-b97c-18cee38d6df2"
MINERVA_ARION_ENDPOINT="6621ca70-103f-4670-a5a7-a7d74d7efbb7"

function GLOBUS_download_one_file {
    remote_path="${1#ftp://ftp.sra.ebi.ac.uk}"  # e.g., /1000g/data/sample.vcf.gz
    local_path="$2"   # e.g., /~/downloads/sample.vcf.gz


    if [ -z "$remote_path" ] || [ -z "$local_path" ]; then
        echo "Usage: download_one_file <remote_path> <local_path>"; return 1;
    fi

    # Single-item transfer: remove --batch and provide full paths
    globus transfer \
        "${EMBL_EBI_ENDPOINT}:${remote_path}" \
        "${MINERVA_ARION_ENDPOINT}:${local_path}" \
        --label "Single Sample Download" \
        --verify-checksum \
        --sync-level checksum
}

function GLOBUS_get_size_of_remote_file() {
        remote_path="${1}"
        globus ls "EMBL_EBI_ENDPOINT:${remote_path}" --format unix --jmespath "DATA[0].size"
}

# ---------- AWS S3 ------------
BUCKET_NAME="platinum-pedigree-data"
function S3_download_one_file {
	remote_path="${1}"
	local_path="${2}"
	module load awscli
	aws s3 cp "${remote_path}" "${local_path}" --no-sign-request --region us-west-1
}
function S3_get_size_of_remote_file() {
	remote_path="${1#s3://${BUCKET_NAME}/}"
	module load awscli
	aws s3api head-object \
    		--bucket "${BUCKET_NAME}" \
    		--key "${remote_path}" \
    		--query 'ContentLength' \
    		--output text
}
# This executes the function name passed from Python
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    "$@"
fi
