def Dataset:
    def __init__(self, name, database):
        self.name = name
        self.database = self.add_to_database(database)

    def add_to_database(self, database):
        self.database = database

