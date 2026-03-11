import pandas as pd
import os

PROJECT_ROOT = next(p for p in Path(__file__).resolve().parents if p.name == "RodrioData")
PATH_OF_DATASETS_TSV_FILE = os.path.join(PROJECT_ROOT, "datasets", "datasets.tsv")

data_in_datasets_tsv_file = pd.read_csv(PATH_OF_DATASETS_TSV_FILE, sep="\t")

class MetadataOfIndexFiles:
    def __init__(self, identifier_of_index_file):
        self.identifier_of_index_file = identifier_of_index_file
        self.attributes = {
                
                }


        attribute_type_specifier(
    def get(self, attribute):
        if attribute k


class UrlHandler:
    def __init__(self, dataset_name, index_file, samples=None, names_of_url_columns_to_be_accessed=None):
        self.sample_identifier_column
        self.sample_identifiers = sample_identifiers
        if len(sample_identifiers) != 0:
            self.sample_identifiers = sample_identifiers
        else:
            self.sample_identifiers = data_in_datasets_tsv_file[self.data_in_datasets_tsv_file["dataset_name"] == dataset_name]]["sample_identifier_column"]
        
        names_of_url_columns_specified_in_dataset_metadata = data_in_datasets_tsv_file[self.data_in_datasets_tsv_file["dataset_name"] == dataset_name]]["url_columns"].split('; ')
        if len(names_of_url_columns_to_be_accessed) != 0:
            for col in names_of_url_columns_to_be_accessed:
                if col is not in names_of_url_columns_specified_in_dataset_metadata:
                    raise RuntimeError(f"name of url column to be accessed {col} is not specified in the metadata.")
                else:
                    continue
                self.names_of_url_columns_to_be_accessed.append(col)
    `   else:
            self.names_of_url_columns_to_be_accessed = names_of_url_columns_specified_in_dataset_metadata
   
    def get_urls(self):
        df = pd.read_csv(self.index_file, sep="\t")
        urls = []
        for sample in sample_identifiers:
            for col in self.names_of_url_columns_to_be_accessed:
                url = df[df[]]sample, col]
                urls.append(url)
        return urls
    
    
