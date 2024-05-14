import pandas as pd
import os
import sys
from parse_tabular_blast import parse_tabular_blast_results #https://gist.github.com/peterk87/5513274

#### FUNCTIONS ####

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


def format_dfresult(dfresult):
    # rename columns
    dfresult.rename(columns={"reads": "read-count","level_0": "read", "level_1": "subject", "level_2": "blast_result_num"}, inplace=True)
    # delete columns
    dfresult.drop(columns=['blast_result_num','taxoID_kraken2','sample_kraken2'],axis=1, inplace=True)
    # split the sscientific name column to be able to compare it with the kraken@ name output
    dfresult[['name_prefix_blast', 'name_rest']] = dfresult['sscinames'].str.split(' ', expand=True, n=1)
    #stripping whitespace from the name column   
    dfresult['name'] = dfresult['name'].apply(lambda x: x.strip())
    # comparing the name and the name_prefix_blast columns generating a new column with the comparison result
    return(dfresult)


def compare_names(dfresult):
    #dfresult['name_comparison']=dfresult['name_prefix_blast'].equals(dfresult['name'])
    dfresult['name_comparison']=(dfresult['name_prefix_blast'] == dfresult['name'])
    return(dfresult)    

#### Main ####
def main():
    if len(sys.argv) == 0:
        print('read file and Kraken output file paths are missing as command line arguments!!!')
    results_path = sys.argv[1]
    

    #results_path = '../../run15_WGS_test/kraken2-results_run15_5prime-trimmed/EuPathDB48/'

    print(get_sample_names(results_path))
    #print(strip_samplenames(get_sample_names(results_path),results_path))

    #column_names_G_taxo = ['sample','taxoID','name','reads']
    df_G_taxo = read_G_taxoIDs(results_path)
    print(df_G_taxo)
    
    dfresult_dict = []
    for sample in get_sample_names(results_path):
        #print(sample)
        taxoids = df_G_taxo.loc[df_G_taxo['sample'] == sample, 'taxoID']
        dfresult_taxoid_dict = []
        for taxoid in taxoids:
            #print(taxoid)
            blast_result_df = blast_result_as_df(taxoid,sample,results_path)
            if not blast_result_df.empty:
                df_temp = pd.merge(df_G_taxo, blast_result_df, how='inner', left_on=['taxoID','sample'], right_on=['taxoID_kraken2','sample_kraken2'],left_index=False, right_index=False, sort=True,suffixes=('_x', '_y'), indicator=False)
                dfresult_taxoid_dict.append(df_temp)
                #print(dfresult_taxoid_dict)
        dfresult_taxoid = pd.concat(dfresult_taxoid_dict, ignore_index=True)
        dfresult_dict.append(dfresult_taxoid)
        #print(dfresult_taxoid)
    dfresult = pd.concat(dfresult_dict, ignore_index=True)
    
    # formatting the dfresult
    dfresult = format_dfresult(dfresult)
    
    # comparing the names from the blast and kraken2 outputs
    dfresult = compare_names(dfresult)
    #print(dfresult)
    dfresult.to_csv(results_path+'kraken_blast_comparison.tsv', sep='\t', index=False, header=True)

    dfresult_true = dfresult[dfresult.name_comparison == True].copy()
    print(dfresult_true)
    dfresult_true.to_csv(results_path+'kraken_blast_comparison_true.tsv', sep='\t', index=False, header=True)

    dfresult_true_sorted = dfresult_true[dfresult_true.groupby(['sample','taxoID','name','read-count','read'])['bitscore'].transform('max') == dfresult_true['bitscore']]
    print(dfresult_true_sorted)
    dfresult_true_sorted.to_csv(results_path+'kraken_blast_comparison_true_highetscore.tsv', sep='\t', index=False, header=True)


if __name__ == "__main__":
    main()
