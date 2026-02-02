# RodrioData

Helps get Bioinformatics datasets quickly (Aspera, Globus, etc.).

# General idea:
The script has datasets in 
```
script.py
datasets/
         1KG.txt
          HGSV.txt
          PUBMED_ID.txt
```

It's modular, so you can add a dataset at any time.
```
python script.py download --dataset 1KG --scratch_dir --run_globus
python script.py download --dataset HGSV --scratch_dir --run_globus
python script.py download --dataset ONT_VIENNA --scratch_dir --run_globus
python script.py download --dataset PUBMED_ID --scratch_dir --run_globus
python script.py download --dataset <Future dataset> --scratch_dir --run_globus
```

Script knows dataset locations on the web. Either downloads in batches (if in scratch) or otherwise providing necessary information to download it on their own.


# TODO:
## User options

## Batch options

Each batch's size limit, in bytes. The script will output an estimate of how many batches you probably need. You can decide this value based on how much space you want the dataset to occupy in `scratch` at any given moment. 
```
--batch_size
```

The number of batches. The script will output an estimate of how big each batch will be. 
```
--n_batches
```

Downloads the full dataset.
```
--full_dataset
```

## Retrieval options

```
--download
```
Returns just the index file for the dataset you want.
```
--get_index
```
