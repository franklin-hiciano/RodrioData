from utils.utils import xlsx_to_tsv
import pandas as pd

class ExcelIndexFileDownloader(IndexFileDownloader):
    def __init__(self, index_file):
        super().__init__(index_file)
        self.download_xlsx_file = self.download
        self.xlsx_file_path = None

    @staticmethod
    def extract_sheet_from_xlsx(xlsx_file, sheet_name):
        clean_name = "".join([c if c.isalnum() else "_" for c in sheet_name])
        output_prefix = xlsx_file.replace('.xlsx', '')
        output_file = f"{output_prefix}_{clean_name}.tsv"
        df = pd.read_excel(xlsx_file, sheet_name=sheet_name)
        df.to_csv(output_file, sep='\t', index=False)

    def extract_index_from_xlsx(self, sheet_name):
        self.xlsx_file_path = self.index_file.path
        self.index_file.set_path(self.xlsx_file_path)
        ExcelIndexFileDownloader.extract_sheet_from_xlsx(xlsx_file=self.xlsx_file_path, sheet_name=sheet_name)

    def download(self, sheet_name):
        self.download_xlsx_file()
        self.extract_index_from_xlsx(sheet_name)                        
            
