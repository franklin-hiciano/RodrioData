class IndexFile:
    def __init__(self, path=None, url=None, database=None):
        self.path = path
        self.url = url
        self.database = database

    def set_path(self, path):
        self.path = path

    def set_url(self, url):
        self.url = url

    def download(self):
        # Implement download logic here
        pass


    