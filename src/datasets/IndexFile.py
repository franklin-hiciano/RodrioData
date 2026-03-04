import argparse
import json
from pathlib import Path
import os

PROJECT_ROOT = next(p for p in Path(__file__).resolve().parents if p.name == "RodrioData")
JSON_OF_INDEX_FILES = os.path.join(PROJECT_ROOT, "datasets", "dataset.json")

#interface for reading and interaxcting with the index fiels
class IndexFile:
    def __init__(self, file_path):
        self.file_path = file_path
        self.entry_in_json_file = self.read_entry_from_json()
        self.dataset_name = self.entry_in_json_file["dataset_name"]
        self.sample_identifier_column = self.entry_in_json_file["sample_identifier_column"]
        self.url_columns = self.entry_in_json_file["url_columns"]

    def read_entry_from_json(self):
        with open(JSON_OF_INDEX_FILES, 'r') as f:
            index_files_in_json = json.load(f)
        try:
            index_file_identifier = self.file_path
            entry_in_json_file = index_files_in_json[index_file_identifier]
            return entry_in_json_file
        except KeyError as ke:
            raise RuntimeError(f"IndexFile cannot be instantiated without an entry in the json file with identifier \"{self.file_path}\". Create one manually or using \"IndexFile.create_new_entry_in_json(filepath=..., dataset_name= ...) with the necessary parameters.") 
        
    def add_row(self, **kwargs):
        new_row = {}
        for column in self.dataframe_with_information_of_index_file.columns:
            new_row[column] = kwargs.get(column, pd.NA)
        new_row_as_dataframe = pd.DataFrame([row_data])
        self.dataframe_with_information_of_index_file = pd.concat([self.dataframe_with_information_of_index_file, new_row_as_dataframe], \
                ignore_index=True)

    def add_new_index_file_to_json(*, file_path=None, dataset_name=None, sample_identifier_column=None, url_columns=None):
        self.file_path = file_path
        self.dataset_name = dataset_name
        self.sample_identifier_column = sample_identifier_column
        self.url_column = url_column
        self.write_to_json()

    def write_to_json(self):
        with open(JSON_OF_INDEX_FILES, 'r') as f:
            index_files_in_json = json.load(f)
        # file path is the identifier 
        identifier = self.file_path
        new_entry_in_json_file = {
                "dataset_name": self.dataset_name,
                "url_columns": self.url_columns,
                "sample_identifier_columns": self.sample_identifier_column
                }
        index_files_in_json.append(identifier, new_entry_in_json_file)
        with open(JSON_FILE, 'w') as f:
            json.dump(index_files_in_json, f, indent=4)

     
def main():
    
    parser = argparse.ArgumentParser(prog="program", description="Script description")
    subparsers = parser.add_subparsers(dest="command")

    # --------------- Adding a new index file to the json -----------------
    add_new_index_file_to_json_subcommand = subparsers.add_parser("add_new_index_file_to_json", help="Adds a new entry to the json which stores information about the index files available in this program. Each entry corresponds to one index file.")  
    add_new_index_file_to_json_subcommand.add_argument("--file_path", help="The file path of the index file. Also serves as the identifier for the index file in the json.")
    add_new_index_file_to_json_subcommand.add_argument("--dataset_name", help="Name of the folder for a specific dataset. Examples include 1KG_ONT_VIENNA, platinum_pedigree, etc. Since one dataset can have multiple index files, you can use this dataset_name for multiple index files.")
    add_new_index_file_to_json_subcommand.add_argument("--sample_identifier_column", help="The column that serves as an identifier for the sample, like sample_id. One sample id might have more than one downloadable file under it, but it should always correspond to that sample -- no two samples should have the same sample_id.") 
    add_new_index_file_to_json_subcommand.add_argument("--url_columns", nargs="+", help="One or more names of columns containing urls.")
    
    add_new_index_file_to_json_subcommand.set_defaults(
        func=lambda args: IndexFile.add_new_index_File_to_json(
            file_path=args.file_path,
            dataset_name=args.dataset_name,
            sample_identifier_column=args.sample_identifier_column,
            url_columns=args.url_columns
        )
    )
    
    args = parser.parse_args() 

if __name__ == "__main__":
    main()
