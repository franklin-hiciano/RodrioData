from ..datasets.IndexFile import IndexFile 
from ..datasets.UrlWrangler import UrlWrangler
x = UrlWrangler(IndexFile("datasets/1KG_ONT_VIENNA/1KG_ONT_VIENNA_manifest.tsv"), 'e', "/sc/arion/work/hiciaf01/projects/RodrioData")
