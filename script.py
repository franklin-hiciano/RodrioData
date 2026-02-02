import subprocess
import argparse
import os
  

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

# Example Calls
transfer_files("--with_globus", "data_sample.zip")
transfer_files("--with_aspera", "backup_file.tar.gz")

def main():
    parser = argparse.ArgumentParser("A script that embeds the changeo file.")
    parser.add_argument("--download", type=str, help="Download the files.")
    parser.add_argument("--dataset", type=str, help="Specifies dataset to be downloaded.")
    parser.add_argument("--scratch_dir", type=str, help="Specifies to download to scratch dir.")
    parser.add_argument("--run_globus", type=str, help="Downloads it using Globus, if available..")
    parser.add_argument("--run_aspera", type=str, help="Downloads it using Aspera, if available.")
    args = parser.parse_args()


if __name__ == '__main__':
    main()
