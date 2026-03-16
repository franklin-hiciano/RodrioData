import json
from pathlib import Path
import os
from .Dataset import Dataset 


PROJECT_ROOT = next(p for p in Path(__file__).resolve().parents if p.name == "RodrioData")
JSON_OF_INDEX_FILE_METADATA = os.path.join(PROJECT_ROOT, "datasets", "datasets.json")

class UrlWrangler:
    def __init__(self, *, subset_of_dataset, list_of_samples, out_dir):
        self.subset_of_dataset = subset_of_dataset 
        self.list_of_samples = list_of_samples
        # THIS IS PRIMARY / TEMPORARY FOR NOW
        primary_url_column = self.subset_of_dataset.get_metadata_from_json_file()["url_columns"][0]
        self.urls = subset_of_dataset.get_dataframe()[primary_url_column]
        if not Path(out_dir).is_dir():
            print(f"Not a valid out_dir: {out_dir}")
        else:
            pass
        self.outpaths = self.urls.apply(os.path.basename).apply(lambda basename: os.path.join(out_dir, str(basename)))
        self.pairings_of_urls_with_outpaths = list(zip(self.urls, self.outpaths))
        
