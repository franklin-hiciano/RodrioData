import pandas as pd
import os

PROJECT_ROOT = next(p for p in Path(__file__).resolve().parents if p.name == "RodrioData")
PATH_OF_DATASETS_TSV_FILE = os.path.join(PROJECT_ROOT, "datasets", "datasets.tsv")


