import pandas as pd 
import re
import argparse
import json
from pathlib import Path
import os

PROJECT_ROOT = next(p for p in Path(__file__).resolve().parents if p.name == "RodrioData")

class IndexFile:
    def __init__(self, file_path):
        self.file_path = file_path
        self.entry_in_json_file = self.read_entry_from_tsv()
        self.dataset_name = self.entry_in_json_file["dataset_name"]
        self.sample_identifier_column = self.entry_in_json_file["sample_identifier_column"]
        self.url_columns = self.entry_in_json_file["url_columns"]

    def read_entry_from_tsv(self):
        # TODO
        pass
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
        df = pd.read_excel(file_path, sheet_name=sheet_name)
        sheet_name_cleaned = re.sub(r'[^a-zA-Z0-9]', '_', sheet_name)
        output_name = f"{file_path}.{sheet_name_cleaned}.tsv"
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
