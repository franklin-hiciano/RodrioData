import argparse
import json
from pathlib import Path
import os

PROJECT_ROOT = next(p for p in Path(__file__).resolve().parents if p.name == "RodrioData")
JSON_OF_INDEX_FILES = os.path.join(PROJECT_ROOT, "datasets", "dataset.json")

#interface for reading and interaxcting with the index fiels
class IndexFile:
    dataset json shoud have different interface than user.
    the dataset json should be making the indexfile class and the user should be interacting with it
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

    def create_new_entry_in_json(*, file_path=None, dataset_name=None, sample_identifier_column=None, url_columns=None):
        self.file_path = file_path
        self.dataset_name = dataset_name
        self.sample_identifier_column = sample_identifier_column
        self.url_column = url_column
        self.write_to_json()

    def write_to_json(self)
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
    parser = argparse.ArgumentParser(description="Script description")
    
    parser.add_argument("input")
    parser.add_argument("-o", "--output", default="output.txt")
    parser.add_argument("-n", "--number", type=int, default=10)
    parser.add_argument("-v", "--verbose", action="store_true")

    args = parser.parse_args()
    
    index_file = IndexFile(name = args.name, filepath = args.filepath, sample_identifier_column = args.sap)

    filepath = 

    print(f"Input: {args.input}")
    if args.verbose:
        print(f"Number: {args.number}")
    print(f"Output: {args.output}")

if __name__ == "__main__":
    main()
