from abc import ABC, abstractmethod
import os 
import subprocess

DIR=$(cd -- "$(dirname -- "$0")" && pwd)
PROJECT_ROOT="${DIR%%RodrioData*}/RodrioData"

class FileTransferer:
    def __init__(self):
        self.PATH_TO_BASH_UTILITY_SCRIPT = None
    
    def run_function_declared_in_bash_utility_script(func_name, *args):
        cmd = [self.PATH_TO_BASH_UTILITY_SCRIPT, func_name] + list(args)
        return subprocess.run(cmd, capture_output=True, text=True, check=True)

    def download_one_file(self, url, local_path):
        run_function_declared_in_bash_utility_script("download_one_file", url)

    def get_size_of_remote_file(self, url):
        run_function_declared_in_bash_utility_script("check_file_size", url)
        # if you can't implement this, just download the file and get the size locally

class StandardCurl(FileTransferer):
    def __init__(self):
        super().__init__()
        self.PATH_TO_UTILITY_SCRIPT=os.path.join(PROJECT_ROOT, "src", "datasets", "downloading_functions", "curl.sh")

class Globus(FileTransferer):
    def __init__(self):
        super().__init__()
        self.PATH_TO_UTILITY_SCRIPT=os.path.join(PROJECT_ROOT, "src", "datasets", "downloading_functions", "globus.sh")
