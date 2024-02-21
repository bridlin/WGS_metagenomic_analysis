import pandas as pd
import os
# import sys
# from dataclasses import dataclass
#from auto_read-Extraction import get_sample_names
#from auto_read-Extraction import strip_samplenames


#### Methodes ####

def get_sample_names(results_path):
    #print(results_path)
    sample_names = []
    for root, dirs, files in os.walk(results_path):
        print(root)
        print(dirs)
        print(files)
        for names in files:
            #print(files)
            #print(names)
            if os.path.splitext(names)[1] == ".k2report":
                 sample_names.append(os.path.splitext(names)[0])
    return sample_names    

def strip_samplenames(sample_name,kraken_file_path):
    substring = kraken_file_path.split('/')
    print(substring)
    striped_name = sample_name.split(substring[-2])
    return striped_name[0]





def read_G_taxoIDs(results_path):
    for root, dirs, files in os.walk(results_path):
        for file in files:
            if file == "G_TaxoIDs_per_sample.tsv" :
                G_taxo = results_path +'/'+ file
                print(G_taxo)
                df_report = pd.read_table(G_taxo,index_col=0)
            else :
                print('there is no G-Taxo file at the indicated result path')
    return df_report    





#### Main ####
def main():
    # if len(sys.argv) == 1:
    #     print('read file and Kraken output file paths are missing as command line arguments!!!')
    # read_file_path = sys.argv[1]
    # kraken_file_path = sys.argv[2] 



    results_path = '../../kraken2-results_run15_5prime-trimmed/EuPathDB48'

    print(get_sample_names(results_path))
    #print(strip_samplenames(get_sample_names(results_path),results_path))

    column_names_G_taxo = ['sample','taxoID','name','reads']
    print(read_G_taxoIDs(results_path))





if __name__ == "__main__":
    main()
