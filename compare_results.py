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
    if not dict_blast:
        df_blast = pd.DataFrame()
        
    else:
        df_blast = pd.DataFrame.from_dict(dict_blast, orient='index').stack().apply(pd.Series).stack().apply(pd.Series)
        df_blast["taxoID_kraken2"] = taxoid
        df_blast["sample_kraken2"] = sample_name
        df_blast.reset_index(inplace=True)  
    return(df_blast)


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
    
    dfresult = []
    for sample in get_sample_names(results_path):
        print(sample)
        taxoids = df_G_taxo.loc[df_G_taxo['sample'] == sample, 'taxoID']
        dfresult_taxoid = []
        for taxoid in taxoids:
            print(taxoid)
            blast_result_df = blast_result_as_df(taxoid,sample,results_path)
            if not blast_result_df.empty:
                df_temp = pd.merge(df_G_taxo, blast_result_df, how='inner', left_on=['taxoID','sample'], right_on=['taxoID_kraken2','sample_kraken2'],left_index=False, right_index=False, sort=True,suffixes=('_x', '_y'), indicator=False)
                dfresult_taxoid.append(df_temp)
                print(dfresult_taxoid)
        final_taxo = pd.concat(dfresult_taxoid, ignore_index=True)
        dfresult.append(final_taxo)
        #print(final_taxo)
    dfresult = pd.concat(dfresult, ignore_index=True)
    print(dfresult)


if __name__ == "__main__":
    main()
