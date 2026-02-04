import subprocess
import argparse
import os

datasets=[]
dataset=None


def transfer_files(method_flag, file_path):
    abs_path = os.path.abspath(file_path)
    
    # $1 will be the method_flag, $2 will be the abs_path
    command = f"bash ./download_dataset.sh {method_flag} {abs_path}"
    
    try:
        result = subprocess.run(
            command,
            shell=True,
            executable='/bin/bash',
            capture_output=True,
            text=True
        )
        
        if result.returncode == 0:
            print("Success:", result.stdout)
        else:
            print("Bash Error:", result.stderr)
            
    except Exception as e:
        print(f"Python Error: {e}")


def download_with_globus(batch_file):
    transfer_files("--with_globus", batch_file) 

def download_with_aspera(fofn):
    transfer_files("--with_aspera", fofn) 

# ---------------- functions for making batch files for globus -------------- 



def make_batch_file(out_path):
    # make a function prepare_batch_file_for_ONT, for example, using the dataset variable, and then call it here.
    # if dataset == 
    pass

# ----------------- functions for making fofn files for aspera ------------

def make_fofn(out_path):
    # same thing here
    pass

def download():
    if args.run_globus:
        batch_file_path=os.path.join(os.getcwd(), "globus_batch_file.txt")
        make_batch_file(batch_file_path)
        download_with_globus(batch_file_path)
    elif args.run_aspera:
        fofn_path=os.path.join(os.getcwd(), "aspera_fofn.txt")
        make_batch_file(fofn_path)
        download_with_globus(fofn_path)
    else:
        print("No download method!")

def make_fofn_only():
    if args.run_globus:
        batch_file_path=os.path.join(os.getcwd(), "globus_batch_file.txt")
        make_batch_file(batch_file_path)
    elif args.run_aspera:
        fofn_path=os.path.join(os.getcwd(), "aspera_fofn.txt")
        make_batch_file(fofn_path)
    else:
        print("No download method!")

# functions for downloading in batches
def download_once_in_batches:
    pass




def main():
    parser = argparse.ArgumentParser("A script that embeds the changeo file.")
    
    parser.add_argument("--download", type=str, help="Download the files.")
    parser.add_argument("--fofn_only", type=str, help="Gives files; either a globus batch file, aspera fofn, etc. for the files.")
    parser.add_argument("--dataset", type=str, help="Specifies dataset to be downloaded.")
    parser.add_argument("--scratch_dir", type=str, help="Specifies to download to scratch dir.")
    parser.add_argument("--run_globus", action="store_true", type=str, help="Downloads it using Globus, if available..")
    parser.add_argument("--run_aspera", action="store_true", type=str, help="Downloads it using Aspera, if available.")
    args = parser.parse_args()
    dataset = args.dataset
    if args.download:
        download()
    elif args.fofn_only:
        make_fofn_only()

if __name__ == '__main__':
    main()
