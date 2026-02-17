import requests

class IndexFileDownloader:
    def __init__(self, index_file):
        self.index_file = index_file

    def download(self):
        if self.index_file.url:
            print(f"Downloading index file from {self.index_file.url}...")
            response = requests.get(self.index_file.url)
            if response.status_code == 200:
                print("Download successful.")
            else:
                print(f"Failed to download index file. Status code: {response.status_code}")
        else:
            print("No URL provided for the index file.")