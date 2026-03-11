#!/bin/bash
set -e -x
set -euo pipefail

DIR=$(cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT="${DIR%%RodrioData*}/RodrioData"

function download_one_file {
	url="${1}"
	curl -L -O "${file}"
}

check_file_size() {
    curl -sI "$1" | grep -i "Content-Length" | awk '{print $2}' | tr -d '\r'
}
