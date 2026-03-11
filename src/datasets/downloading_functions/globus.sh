#!/bin/bash
set -e -x
set -euo pipefail

DIR=$(cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT="${DIR%%RodrioData*}/RodrioData"

EMBL_EBI_ENDPOINT="47772002-3e5b-4fd3-b97c-18cee38d6df2"
MINERVA_ARION_ENDPOINT="6621ca70-103f-4670-a5a7-a7d74d7efbb7"

function download_one_file {	
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

function get_size_of_remote_file() {
	remote_path="${1}"
	globus ls "EMBL_EBI_ENDPOINT:${remote_path}" --format unix --jmespath "DATA[0].size"	
}
# This executes the function name passed from Python
"$@"
