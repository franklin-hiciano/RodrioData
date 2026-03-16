import argparse
from datasets.IndexFile import IndexFile
from datasets.UrlWrangler import UrlWrangler
from datasets.UrlDownloader import UrlDownloader

def download_one_sample(*, sample, index_file_path, out_dir, **column_subset_values):
    print("downloading one sample")
    index_file_subsetted_to_specific_column_values = IndexFile(file_path=index_file_path)
    index_file_subsetted_to_specific_column_values.subset_by_specific_column_values(**column_subset_values)
    pairings_of_urls_with_outpaths = UrlWrangler(user_index=index_file_subsetted_to_specific_column_values, list_of_samples=[sample], out_dir=out_dir).pairings_of_urls_with_outpaths
    # ALSO DYNAMICALLY FETCH THE DOWNLOAD METHOD FROM THE JSON FILE 
    UrlDownloader(pairings_of_urls_with_outpaths=pairings_of_urls_with_outpaths, platform="S3").download_files()

def main():
    parser = argparse.ArgumentParser(prog="program", description="Script description")
    subparsers = parser.add_subparsers(dest="command")

    

    # --------------- Read Subset -----------------
    read_subset_subcommand = subparsers.add_parser("download_one_sample", help="Read a subset of data.")
    read_subset_subcommand.add_argument("--sample", required=True, help="Path to output TSV file.")
    # TODO:
    # 1. Change it to one index file, one dataset, as discussed
    # 2. Implement ability to download multiple samples
#    read_subset_subcommand.add_argument("--dataset", required=True, help="Path to output TSV file.")
    read_subset_subcommand.add_argument("--index_file_path", help="Path to the index file.")
    read_subset_subcommand.add_argument("--out_dir", required=True, help="Path to output directory.")
    read_subset_subcommand.set_defaults(
        func=lambda args: download_one_sample(
            sample=args.sample,
            index_file_path=args.index_file_path,
            out_dir=args.out_dir,
             **args.kwargs
        )
    )

    # --- Parse args AFTER all subcommands are defined ---
    args, unknown = parser.parse_known_args()

    # Parse dynamic --key value pairs into kwargs
    kwargs = {}
    it = iter(unknown)
    for token in it:
        if token.startswith("--"):
            key = token.lstrip("-")
            try:
                val = next(it)
            except StopIteration:
                val = True
            kwargs[key] = val

    args.kwargs = kwargs
    if hasattr(args, 'func'):
        args.func(args)
    else:
        parser.print_help()


if __name__ == '__main__':
    main()
