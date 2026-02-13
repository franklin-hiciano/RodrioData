import pandas as pd
import os
import gdown

def download_from_google_drive(file_id, output):
    url = f'https://drive.google.com/uc?id={file_id}'
    gdown.download(url, output, quiet=False)


def xlsx_to_tsv(input_file, output_prefix, sheets_to_extract):
    """
    Stops and raises an error if any requested sheet is missing.
    """
    for sheet in sheets_to_extract:
        df = pd.read_excel(input_file, sheet_name=sheet)

        clean_name = "".join([c if c.isalnum() else "_" for c in sheet])
        output_file = f"{output_prefix}_{clean_name}.tsv"

        df.to_csv(output_file, sep='\t', index=False)
        print(f"Successfully saved {sheet}")
