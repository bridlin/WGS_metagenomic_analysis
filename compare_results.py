import pandas as pd
import os
# import sys
# from dataclasses import dataclass
#from auto_read-Extraction import get_sample_names
#from auto_read-Extraction import strip_samplenames
from parse_tabular_blast import parse_tabular_blast_results

#### Methodes ####

def get_sample_names(results_path):
    #print(results_path)
    sample_names = []
    for root, dirs, files in os.walk(results_path):
        # print(root)
        # print(dirs)
        # print(files)
        for file in files:
            #print(files)
            #print(names)
            if os.path.splitext(file)[1] == ".k2report":
                 sample_names.append(os.path.splitext(file)[0])
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
                G_taxo = results_path + '/' + file
                #print(G_taxo)
                df_report = pd.read_table(G_taxo,index_col=0)       
    return df_report    

def read_blast_result(results_path):
    for root, dirs, files in os.walk(results_path):
        for file in files:
            if (os.path.splitext(file)[1] == ".fa_blast") :
                print(os.path.splitext(file)[0])
                blast_result = results_path + '/' + 'blast_result/' + file
                print(blast_result)
                df_blast_result = pd.read_table(blast_result)
    return df_blast_result

def blast_result_as_df(taxoid,sample_name,result_path):
    blastfile = result_path + '/blast_result_6/' + sample_name + '.tid' + str(taxoid) + '.1.fa_blast'       
    dict_blast = parse_tabular_blast_results(blastfile)
    #print(dict_blast)
    # df_blast = pd.DataFrame.from_dict(dict_blast, orient='index').stack().apply(pd.Series).stack().apply(pd.Series)
    return(dict_blast)
   
#### Main ####
def main():
    # if len(sys.argv) == 1:
    #     print('read file and Kraken output file paths are missing as command line arguments!!!')
    # read_file_path = sys.argv[1]
    # kraken_file_path = sys.argv[2] 

    results_path = '../../run15_WGS_test/kraken2-results_run15_5prime-trimmed/EuPathDB48/'

    print(get_sample_names(results_path))
    #print(strip_samplenames(get_sample_names(results_path),results_path))

    #column_names_G_taxo = ['sample','taxoID','name','reads']
    df_G_taxo = read_G_taxoIDs(results_path)
    print(df_G_taxo)
    
    #for name, values in df_G_taxo.items():
        #print(name)
        #print(values)
        #print('{name}: {value}'.format(name=name, value=values[0]))
        # if name == 'taxoID':
        #     taxoid=values
        #     print(taxoid)
        #     print(str(taxoid))
        #     print('../../run15_WGS_test/kraken2-results_run15_5prime-trimmed/EuPathDB48/blast_result_6/1528T_S2_EuPathDB48.tid' + str(taxoid) + '.1.fa_blast')
    for sample in get_sample_names(results_path):
        for column in df_G_taxo.columns[1:2]:
            for taxoid in (df_G_taxo[column]):
                print(taxoid) 
                print('../../run15_WGS_test/kraken2-results_run15_5prime-trimmed/EuPathDB48/blast_result_6/1528T_S2_EuPathDB48.tid' + str(taxoid) + '.1.fa_blast')
                print(results_path)
                print(sample)   
                print(blast_result_as_df(taxoid,sample,results_path))

    
    
    # dict_blast = parse_tabular_blast_results('../../run15_WGS_test/kraken2-results_run15_5prime-trimmed/EuPathDB48/blast_result_6/1528T_S2_EuPathDB48.tid55193.1.fa_blast')
    # #print(dict_blast)
    # df_blast = pd.DataFrame.from_dict(dict_blast, orient='index').stack().apply(pd.Series).stack().apply(pd.Series)
    # print(df_blast)

    

if __name__ == "__main__":
    main()
