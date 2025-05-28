import pandas as pd
import sys
import os


#### FUNCTIONS ####

### read in as df the table with Genus taxo IS and reads number per sample
def read_chunk_blast_result(results_path):
    print(results_path) 
    for root, dirs, files in os.walk(results_path):
        print(files)
        for file in files:
            print(file)
            if os.path.splitext(file)[1] == ".fasta_blast": 
                chunk_blast = results_path + '/' + file
                df_chunk_blast = pd.read_table(chunk_blast,index_col=None,header=None)       
    return df_chunk_blast  


def split_first_column(df):
    df[[0]]= df.iloc[:,0].astype("string").str.split("|", expand=True)
    return df


print("hello")

#### Main ####
def main():
    print("hello")
    # if len(sys.argv) == 1:
    #     print('input file paths are missing as command line arguments!!!')
    # else:
    #     results_path = sys.argv[1]
    #     print(results_path)
    results_path = '../blast_results/'

    print(results_path) 


 # getting the Kraken results from the Genus taxon file as df
    df_chunk_blast = read_chunk_blast_result(results_path)
    print(df_chunk_blast)

    print(split_first_column(df_chunk_blast))



if __name__ == "__main__":
    main()