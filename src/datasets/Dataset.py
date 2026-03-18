import pandas as pd 
import re
import argparse
import json
from pathlib import Path
import os

PROJECT_ROOT = next(p for p in Path(__file__).resolve().parents if p.name == "RodrioData")
JSON_OF_METADATA_OF_DATASETS = os.path.join(PROJECT_ROOT, "datasets", "datasets.json")
class Dataset:
    def __init__(self, *, name):
        self.name = name
        with open(JSON_OF_METADATA_OF_DATASETS, "r") as f:
            metadata_of_datasets = json.load(f)
            self.metadata_from_json_file = [dataset_metadata for dataset_metadata in metadata_of_datasets if dataset_metadata["dataset_name"] == self.name][0]
        self.index_file_path = self.metadata_from_json_file["index_file_path"]
        try:
            with open(self.index_file_path, 'r') as f:
                pass
        except FileNotFoundError:
            try:
                self.index_file_path = os.path.join(PROJECT_ROOT, self.index_file_path)
                with open(self.index_file_path, 'r') as f:
                    pass
            except FileNotFoundError:
                print(f"index file path is invalid: {self.index_file_path}")
        self.data = pd.read_csv(self.index_file_path, sep="\t")
        
    def subset_by_specific_column_values(self, **kwargs):
        for col_name, value in kwargs.items():
            self.data = self.data[self.data[col_name]==value]

    def write(self, *, output_path):
        self.data.to_csv.to_csv(output_path, sep="\t", index=False)
    
    def get_dataframe(self):
        return self.data
    
    def get_metadata_from_json_file(self):
        return self.metadata_from_json_file

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
    def excel_to_tsv(cls, file_path, sheet_name):
        df = pd.read_excel(file_path, sheet_name=sheet_name, engine='openpyxl')
        sheet_name_cleaned = re.sub(r'[^a-zA-Z0-9]', '.', sheet_name)
        base_path, _ = os.path.splitext(file_path)
        output_name = f"{base_path}.{sheet_name_cleaned}.tsv"
        df.to_csv(output_name, sep='\t', index=False)

    @classmethod
    def download_from_drive(cls, drive_id, out_path):
        import gdown
        url = f'https://drive.google.com/uc?id={drive_id}'
        gdown.download(url, out_path, quiet=False)

    def run_function_declared_in_bash_utility_script(func_name, *args):
        cmd = [self.PATH_TO_BASH_UTILITY_SCRIPT, func_name] + list(args)
        return subprocess.run(cmd, capture_output=True, text=True, check=True)

def main():
    
    parser = argparse.ArgumentParser(prog="program", description="Script description")
    subparsers = parser.add_subparsers(dest="command")

# --------------- Excel to TSV Converter -----------------
    excel_subcommand = subparsers.add_parser("excel_to_tsv", help="Convert an Excel sheet to a TSV file.")
    excel_subcommand.add_argument("file_path", help="Path to the .xlsx file.")
    excel_subcommand.add_argument("--sheet_name", required=True, help="Name of the sheet to convert.")

    excel_subcommand.set_defaults(
        func=lambda args: Dataset.excel_to_tsv(
            file_path=args.file_path,
            sheet_name=args.sheet_name
        )
    )

    # --------------- Google Drive Downloader -----------------
    drive_sub = subparsers.add_parser("download_from_drive", help="Download a file from Google Drive.")

    drive_sub.add_argument("--drive_id", required=True, help="The Google Drive file ID.")
    drive_sub.add_argument("--out_path", required=True, help="The local path where the file should be saved.")

    drive_sub.set_defaults(
        func=lambda args: Dataset.download_from_drive(
            drive_id=args.drive_id,
            out_path=args.out_path
        )
    )

    # --------------- Read Subset -----------------
    read_subset_subcommand = subparsers.add_parser("read_index_file_of_dataset_and_write_subset", help="Read a subset of data and write it.")
    read_subset_subcommand.add_argument("--dataset_name", help="Name of the dataset.")
    read_subset_subcommand.add_argument("--output_path", required=True, help="Path to output index file.")
    read_subset_subcommand.set_defaults(
        func=lambda args: Dataset(args.dataset_name).read_index_file_and_write_subset(
            output_path=args.output_path,
            **args.kwargs
        )
    )

    # --- Parse args AFTER all subcommands are defined ---
    args, unknown = parser.parse_known_args()

    if args.command is None:
        parser.print_help()
        return

    # Parse dynamic --key value pairs into kwargs
    kwargs = {}
    it = iter(unknown)
    for token in it:
        if token.startswith("--"):
            key = token.lstrip("-")
            try:
                val = next(it)
            except StopIteration:
                val = True
            kwargs[key] = val

    args.kwargs = kwargs

    if hasattr(args, 'func'):
        args.func(args)
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
