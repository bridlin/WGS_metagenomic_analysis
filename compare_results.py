import pandas as pd
import os
# import sys
# from dataclasses import dataclass
#from auto_read-Extraction import get_sample_names
#from auto_read-Extraction import strip_samplenames


#### Methodes ####

def get_sample_names(results_path):
    print(results_path)
    sample_names = []
    for root, dirs, files in os.walk(results_path):
        for names in files:
            #print(files)
            #print(names)
            if os.path.splitext(names)[1] == ".k2report":
                 sample_names.append(os.path.splitext(names)[0])
    return sample_names    

def strip_samplenames(sample_names,results_path):
    substring = results_path.split('/')
    striped_name = sample_names.split(substring[-2])
    return striped_name[0]


def read_G_taxoIDs(G_taxoIDs, column_names):
    df_report = pd.read_table(G_taxoIDs, names=column_names)
    return df_report














#### Main ####
def main():
    # if len(sys.argv) == 1:
    #     print('read file and Kraken output file paths are missing as command line arguments!!!')
    # read_file_path = sys.argv[1]
    # kraken_file_path = sys.argv[2] 



    results_path = '../../kraken2-results_run15_5prime-trimmed/EuPathDB48'

    print(get_sample_names(results_path))
    print(strip_samplenames(sample_names,results_path))






if __name__ == "__main__":
    main()
