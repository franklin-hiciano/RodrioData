import pandas as pd 
import re
import argparse
import json
from pathlib import Path
import os

PROJECT_ROOT = next(p for p in Path(__file__).resolve().parents if p.name == "RodrioData")
JSON_OF_INDEX_FILES = os.path.join(PROJECT_ROOT, "datasets", "datasets.json")

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

        new_row_as_dataframe = pd.DataFrame([new_row])
        self.dataframe_with_information_of_index_file = pd.concat(
            [self.dataframe_with_information_of_index_file, new_row_as_dataframe],
            ignore_index=True
        )

    @classmethod
    def add_new_index_file_to_json(cls, **kwargs):
        instance = cls.__new__(cls)
        instance.file_path = kwargs.get("file_path")
        instance.dataset_name = kwargs.get("dataset_name")
        instance.sample_identifier_column = kwargs.get("sample_identifier_column")
        instance.url_columns = kwargs.get("url_columns")
        instance.bytes_column = kwargs.get("bytes_column")
        instance.estimated_file_size_in_bytes=kwargs.get("estimated_file_size_in_bytes")
        instance.write_to_json()

    def write_to_json(self):
        if os.path.exists(JSON_OF_INDEX_FILES) and os.path.getsize(JSON_OF_INDEX_FILES) > 0:
            with open(JSON_OF_INDEX_FILES, 'r') as f:
                try:
                    index_files_in_json = json.load(f)
                except json.JSONDecodeError:
                    index_files_in_json = {}
        else:
            index_files_in_json = {}

        identifier = self.file_path
        index_files_in_json[identifier] = {
            "dataset_name": self.dataset_name,
            "url_columns": self.url_columns,
            "sample_identifier_column": self.sample_identifier_column,
            "bytes_column": self.bytes_column,
            "estimated_file_size_in_bytes": self.estimated_file_size_in_bytes
        }
        with open(JSON_OF_INDEX_FILES, 'w') as f:
            json.dump(index_files_in_json, f, indent=4)
     
    @classmethod
    def excel_to_tsv(cls, file_path, sheet_name):
        df = pd.read_excel(file_path, sheet_name=sheet_name)
        sheet_name_cleaned = re.sub(r'[^a-zA-Z0-9]', '_', sheet_name)
        output_name = f"{file_path}.{sheet_name_cleaned}.tsv"
        df.to_csv(output_name, sep='\t', index=False)

    @classmethod
    def download_from_drive(cls, drive_id, out_path):
        import gdown
        url = f'https://drive.google.com/uc?id={drive_id}'
        gdown.download(url, out_path, quiet=False)

def main():
    
    parser = argparse.ArgumentParser(prog="program", description="Script description")
    subparsers = parser.add_subparsers(dest="command")

    # --------------- Adding a new index file to the json -----------------
    add_new_index_file_to_json_subcommand = subparsers.add_parser("add_new_index_file_to_json", help="Adds a new entry to the json which stores information about the index files available in this program. Each entry corresponds to one index file.")  
    add_new_index_file_to_json_subcommand.add_argument("--file_path", help="The file path of the index file. Also serves as the identifier for the index file in the json.")
    add_new_index_file_to_json_subcommand.add_argument("--dataset_name", help="Name of the folder for a specific dataset. Examples include 1KG_ONT_VIENNA, platinum_pedigree, etc. Since one dataset can have multiple index files, you can use this dataset_name for multiple index files.")
    add_new_index_file_to_json_subcommand.add_argument("--sample_identifier_column", help="The column that serves as an identifier for the sample, like sample_id. One sample id might have more than one downloadable file under it, but it should always correspond to that sample -- no two samples should have the same sample_id.") 
    add_new_index_file_to_json_subcommand.add_argument("--url_columns", nargs="+", help="One or more names of columns containing urls.")
    add_new_index_file_to_json_subcommand.add_argument("--bytes_column", help="Column with the file size, IN BYTES, of each file. If this is not provided, at least an estimate should be given.")
    add_new_index_file_to_json_subcommand.add_argument("--estimated_file_size_in_bytes", help="For calculating how many files can be downloaded in one batch with the storage constraints. IN BYTES.")
    

    add_new_index_file_to_json_subcommand.set_defaults(
        func=lambda args: IndexFile.add_new_index_file_to_json(
            file_path=args.file_path,
            dataset_name=args.dataset_name,
            sample_identifier_column=args.sample_identifier_column,
            url_columns=args.url_columns,
            bytes_column=args.bytes_column,
            estimated_file_size_in_bytes=args.estimated_file_size_in_bytes
        )
    )
    
    # --------------- Excel to TSV Converter -----------------
    excel_subcommand = subparsers.add_parser("excel_to_tsv", help="Convert an Excel sheet to a TSV file.")
    excel_subcommand.add_argument("file_path", help="Path to the .xlsx file.")
    excel_subcommand.add_argument("--sheet_name", required=True, help="Name of the sheet to convert.")

    excel_subcommand.set_defaults(
        func=lambda args: IndexFile.excel_to_tsv(
            file_path=args.file_path,
            sheet_name=args.sheet_name
        )
    )

    # --------------- Google Drive Downloader -----------------
    drive_sub = subparsers.add_parser("download_from_drive", help="Download a file from Google Drive.")

    drive_sub.add_argument("--drive_id", required=True, help="The Google Drive file ID.")
    drive_sub.add_argument("--out_path", required=True, help="The local path where the file should be saved.")

    drive_sub.set_defaults(
        func=lambda args: IndexFile.download_from_drive(
            drive_id=args.drive_id,
            out_path=args.out_path
        )
    )
    
    args = parser.parse_args() 

    if hasattr(args, 'func'):
        args.func(args)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
