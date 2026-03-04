import pandas as pd
import re

def excel_to_tsv(file_path, sheet_name):
    df = pd.read_excel(file_path, sheet_name=sheet_name)
    sheet_name_cleaned = re.sub(r'[^a-zA-r0-9]', '_', sheet_name)
    output_name = f"{file_path}.{sheet_name_cleaned}.tsv"
    df.to_csv(output_name, sep='\t', index=False)
    
# Usage
# excel_to_tsv("data.xlsx", "Sheet 1") -> creates "data.xlsx.Sheet_1.tsv"
