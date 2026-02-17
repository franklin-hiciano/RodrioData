import os
import requests

FIELDS = {
    "read_run": [
        "run_accession", "study_accession", "sample_accession", "experiment_accession",
        "sample_title", "tax_id", "scientific_name", "library_layout", "library_strategy",
        "library_source", "library_selection", "instrument_platform", "instrument_model",
        "read_count", "base_count", "cell_type", "tissue_type", "disease", "dev_stage",
        "host", "host_sex", "age", "experimental_factor", "first_public",
        "fastq_ftp", "fastq_md5", "fastq_bytes", "fastq_aspera",
        "submitted_ftp", "submitted_md5", "submitted_bytes", "submitted_aspera",
        "sra_ftp", "sra_md5", "sra_bytes", "sra_aspera",
        "bam_ftp", "bam_md5", "bam_bytes", "bam_aspera",
    ],
    "analysis": [
        "analysis_accession", "study_accession", "sample_accession", "experiment_accession",
        "sample_title", "tax_id", "scientific_name", "analysis_type", "reference_genome",
        "pipeline_name", "pipeline_version", "cell_type", "tissue_type", "disease",
        "dev_stage", "host", "host_sex", "age", "experimental_factor", "first_public",
        "submitted_ftp", "submitted_md5", "submitted_bytes", "submitted_aspera",
        "generated_ftp", "generated_md5", "generated_bytes", "generated_aspera",
    ],
}

BASE_URL = "https://www.ebi.ac.uk/ena/portal/api"

class ENAIndexFileDownloader(IndexFileDownloader):
    def __init__(self, index_file):
        super().__init__(index_file)
    
    def download_schema(self, study_dir, result_data_type):
        response = requests.get(f"{BASE_URL}/returnFields", params={"result": result_data_type})
        response.raise_for_status()
        with open(os.path.join(study_dir, f"schema_{result_data_type}.txt"), "wb") as f:
            f.write(response.content)

    def download_index(self, index_file, study, result_data_type):
        response = requests.get(f"{BASE_URL}/filereport", params={
            "accession": study,
            "result": result_data_type,
            "fields": ",".join(FIELDS[result_data_type]),
        })
        response.raise_for_status()
        with open(index_file.get_path(), "wb") as f:
            f.write(response.content)

    def download(self, study_id, result_data_type, index_file):
        study_dir = os.path.join(os.dirname(index_file.get_path()), f"study_{study_id}")
        os.makedirs(study_dir, exist_ok=True)

        self.download_schema(study_dir, result_data_type)
        self.download_index(index_file, study_id, result_data_type)