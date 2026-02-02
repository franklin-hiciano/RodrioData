#!/bin/bash
set -e -x
set -euo pipefail



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
