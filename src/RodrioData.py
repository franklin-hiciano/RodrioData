from src.datasets.datasets import LocalDatabase

class RodrioData:
    def __init__(self):
        self.databases = {}
        self.datasets = Datasets()
        self.datasets_json = DatasetsJson("datasets.json", self.datasets)

    def create_databases(self):
        databases = Databases("Nucleotide Databases")
        
        return databases
    
    def create_datasets(self):
        datasets = [
            Dataset("1000G_high_coverage", database=self.databases["1KG"]),
            Dataset("1KG_ONT_VIENNA", database=self.databases["1KG"]),
            Dataset("simons", databaseself.databases["1KG"]),

        ]
        
        
        self.datasets.add_dataset
        database = LocalDatabase(name)
        self.datasets.add_dataset(database)

    def create_databases(self):
        databases = Databases("Nucleotide Databases")
        databases.add("ENA")

        return Databases("Nucleotide Databases")
        

        

        
    
    def create_datasets(self, name):
        
        
        datasets = [
            Dataset("1000G_high_coverage"),

        ]
        
        
        self.datasets.add_dataset
        database = LocalDatabase(name)
        self.datasets.add_dataset(database)

