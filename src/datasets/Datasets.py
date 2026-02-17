from src.utils.Dataset import Dataset

class Datasets:
    def __init__(self):
        self.datasets = {}

    def add_dataset(self, dataset):
        self.datasets[dataset.name] = dataset

