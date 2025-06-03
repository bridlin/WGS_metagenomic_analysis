import pandas as pd
import sys
import os
from pathlib import Path

#### FUNCTIONS ####

### reads in as df the blast_chunk results from the chunk_blast_results folder and combine them into one df
def read_chunk_blast_result(results_path):
    print(f"Reading from: {results_path}")
    dataframes = []
    
    for root, dirs, files in os.walk(results_path):
        print(f"Files found in {root}: {files}")
        for file in files:
            print(f"Checking file: {file}")
            if file.endswith(".fasta_blast"):
                file_path = os.path.join(root, file)
                print(f"Reading file: {file_path}")
                df = pd.read_table(file_path, header=None)
                dataframes.append(df)
    
    if dataframes:
        df_chunk_blast = pd.concat(dataframes, ignore_index=True)
    else:
        df_chunk_blast = pd.DataFrame()
    
    return df_chunk_blast

### Splits the first column of the DataFrame into two columns: file name and read name

def split_first_column(df):
    # Split the first column on '|', expand into two columns
    split_cols = df.iloc[:, 0].astype(str).str.split("|", expand=True)
    
    # Rename the new columns for clarity
    split_cols.columns = ['file', 'read_name']

    # Drop the original first column and insert the new ones
    df = df.drop(df.columns[0], axis=1)
    df = pd.concat([split_cols, df], axis=1)
    
    return df

def split_df_by_file_column(df):
    # Get the name (or index) of the last column
    file_col = df.columns[0]
    print(file_col)
    print(f"Last column to split by: {file_col}")
    # Dictionary to hold the resulting sub-DataFrames
    split_dfs = {}
    
    # Group by the last column
    for value, group in df.groupby(file_col):
        # Drop the last column
        sub_df = group.drop(columns=file_col)
        # Store in dictionary with key based on the group value
        split_dfs[str(value)] = sub_df
    
    return split_dfs


print("hello")

#### Main ####
def main():
    print("hello")
    if len(sys.argv) == 1:
        print('Input file paths are missing as command line arguments!!!')
        sys.exit(1)  # Exit the program to avoid NameError

    input_path = Path(sys.argv[1])
    print(input_path)
    
    results_path = input_path / "blast_result"
    print(results_path)
    
    # results_path = '../../chunk_blast_results/'

    print(results_path) 


#   # getting the chunke blast results and de-chunk them into individual blast results
    df_chunk_blast = read_chunk_blast_result(results_path)
    print(df_chunk_blast)

#   # Split the first column into two columns: the read name [0] and the file name
    df_total = split_first_column(df_chunk_blast)
    print(df_total)
#   # split the DataFrame by the last column (which is the file name) and return a list of dfs
    split_dfs = split_df_by_file_column(df_total)
    print(split_df_by_file_column(df_total))


#   # write a file for each df in the df_list
    for key, sub_df in split_dfs.items():
        sub_df.to_csv(f"{results_path}/{key}.fa_blast", sep='\t', index=False, header=False)



if __name__ == "__main__":
    main()