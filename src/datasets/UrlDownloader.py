from .UrlWrangler import UrlWrangler
from pathlib import Path
import os
from typing import Optional, List

PROJECT_ROOT = next(p for p in Path(__file__).resolve().parents if p.name == "RodrioData")
JSON_OF_INDEX_FILE_METADATA = os.path.join(PROJECT_ROOT, "datasets", "datasets.json")

SCRIPT_WITH_DOWNLOADING_FUNCTIONS = os.path.join(PROJECT_ROOT, "src", "datasets", "download_functions.sh")
class UrlDownloader:
    def __init__(self, pairings_of_urls_with_outpaths, *, platform):
        self.pairings_of_urls_with_outpaths = pairings_of_urls_with_outpaths
    def run_downloading_function(func_name: str, args: Optional[List[str]] = None) -> str:
        output = subprocess.run(["bash", script_path, func_name].extend(args), capture_output=True, text=True)
        print(output)

    def download_files(self):
        print("hi!")
        for pairing in self.pairings_of_urls_with_outpaths:
            remote_path = pairing[0]
            local_path = pairing[1]
            self.run_downloading_function(f"{self.platform}_download_one_file", [remote_path, local_path])
        print("Done downloading files.")

    

