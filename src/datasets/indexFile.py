import argparse


#interface for reading and interaxcting with the index fiels
class IndexFile:
    dataset json shoud have different interface than user.
    the dataset json should be making the indexfile class and the user should be interacting with it
    def __init__(self, name, filepath, sample_id_column, url_columns):
        self.name = name
        self.filepath = filepath
        self.dataframe_with_information_of_index_file = pd.read_csv(self.filepath, sep="\t")
        self.url_columns = url_columns
        self.sample_id_column = sample_id_column
    
    def add_row(self, **kwargs):
        new_row = {}
        for column in self.dataframe_with_information_of_index_file.columns:
            new_row[column] = kwargs.get(column, pd.NA)
        new_row_as_dataframe = pd.DataFrame([row_data])
        self.dataframe_with_information_of_index_file = pd.concat([self.dataframe_with_information_of_index_file, new_row_as_dataframe], \
                ignore_index=True)
    
    

     
the caller should always provide the filepath, the name, the url columns ,etc..
def main():
    parser = argparse.ArgumentParser(description="Script description")
    
    parser.add_argument("input")
    parser.add_argument("-o", "--output", default="output.txt")
    parser.add_argument("-n", "--number", type=int, default=10)
    parser.add_argument("-v", "--verbose", action="store_true")

    args = parser.parse_args()
    
    index_file = IndexFile(name = args.name, filepath = args.filepath, sample_id_column = args.sap)

    filepath = 

    print(f"Input: {args.input}")
    if args.verbose:
        print(f"Number: {args.number}")
    print(f"Output: {args.output}")

if __name__ == "__main__":
    main()
