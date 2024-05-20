import pandas as pd
import os
import sys
from parse_tabular_blast import parse_tabular_blast_results #https://gist.github.com/peterk87/5513274 I made some changes to include more fields from the blast results to be parsed
from ete3 import NCBITaxa
ncbi = NCBITaxa()
#ncbi.update_taxonomy_database()

#### FUNCTIONS ####

def get_sample_names(results_path):
    sample_names = []
    for root, dirs, files in os.walk(results_path):
        for file in files:
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
    blastfile = result_path + 'blast_result/' + sample_name + '.tid' + str(taxoid) + '.1.fa_blast'       
    dict_blast = parse_tabular_blast_results(blastfile)
    if not dict_blast:
        df_blast = pd.DataFrame()
        
    else:
        df_blast = pd.DataFrame.from_dict(dict_blast, orient='index').stack().apply(pd.Series).stack().apply(pd.Series)
        df_blast["taxoID_kraken2"] = taxoid
        df_blast["sample_kraken2"] = sample_name
        df_blast.reset_index(inplace=True) # to get the index as columns 
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
    # dropping all duplicates that can arise as we do not parse all fields from the blast results
    dfresult.drop_duplicates(inplace=True)
    dfresult = dfresult.reset_index(drop=True)
    return(dfresult)

def get_genus_taxID(dfresult):
    # get the genus taxID from the taxoID column
    for i,taxid in enumerate(dfresult['taxoid']): 
        #print(dfresult.loc[i,'taxoID'])
        kraken_genus_lineage = ncbi.get_lineage(dfresult.loc[i,'taxoID']) 
        #print(kraken_genus_lineage)
        #print(taxid)
        blast_lineage = ncbi.get_lineage(taxid)
        #print(blast_lineage)
        if blast_lineage is not None and kraken_genus_lineage is not None:  
            genus_position = len(kraken_genus_lineage)
            if (len(blast_lineage) >= genus_position) :
                #print(lineage)
                dfresult.at[i,'genus_taxid'] = blast_lineage[genus_position -1] 
            else:
                dfresult.at[i,'genus_taxid'] = 'NaN'
    return(dfresult)

def compare_names(dfresult):
    # comparing the name and the name_prefix_blast columns generating a new column with the comparison result
    dfresult['name_comparison']=(dfresult['name_prefix_blast'] == dfresult['name'])
    return(dfresult)    

def compare_genus_taxid(dfresult):
    # comparing the genus taxoid from kraken2 result with the genus taxid from the blast result and generating a new column with the comparison result
    dfresult['taxoid_comparison']=(dfresult['taxoID'] == dfresult['genus_taxid'])
    return(dfresult) 


def get_highestbitscore_results(dfresult):
    # get the alignment with highest bitscore (if multiple results the first) for each read independed if name comparison is true or not
    dfresult_bitscoremax = dfresult[dfresult.groupby(['sample','taxoID','name','read-count','read'])['bitscore'].transform('max') == dfresult['bitscore']]
    # select the first max bitscore per read when more than one results have the same max bitscore
    dfresult_bitscoremax_opr = dfresult_bitscoremax.groupby(['sample','taxoID','name','read-count','read','bitscore']).head(1)
    return(dfresult_bitscoremax_opr)

def add_highest_bitscore_if_false(dfresult,dfresult_true_bitscoremax):
    dfresult_bitscoremax_opr = get_highestbitscore_results(dfresult)
    # selecting the rows in dfresult_bitscoremax_opr that are also in dfresult_true_bitscoremax
    dfresult_bitscoremax_opr_intrue = dfresult_bitscoremax_opr[dfresult_bitscoremax_opr['read'].isin(dfresult_true_bitscoremax['read'])]
    #print(dfresult_bitscoremax_opr_intrue)
    # joining the two dfs and dropping all duplicate rows, so that in the end the final df containes all name comparison=true with the highest bitscore rows and all false  rows with the higher bitscore for the same reads if they exist 
    dfresult_true_bitscoremax_concat = pd.concat([dfresult_bitscoremax_opr_intrue, dfresult_true_bitscoremax],ignore_index=True)
    dfresult_true_bitscoremax_concat.drop_duplicates(inplace=True)
    return(dfresult_true_bitscoremax_concat)



#### Main ####
def main():
    if len(sys.argv) == 0:
        print('read file and Kraken output file paths are missing as command line arguments!!!')
        results_path = sys.argv[1]
    

    # results_path = '../../test-run23/kraken2-results_run23_5prime-trimmed/PlusPF/'

    # getting the Kraken results from the Genus taxon file as df
    df_G_taxo = read_G_taxoIDs(results_path)
    print(df_G_taxo)
    

    # getting the blast results as df from blastn outputformat 6 (modified script from https://gist.github.com/peterk87/5513274) and merge tham with the kraken2 results into a single df
    # script blocks if there are no blast results as the list of df is empty and the concat function does not work with empty lists
    dfresult_list = []
    for sample in get_sample_names(results_path):
        #print(sample)
        taxoids = df_G_taxo.loc[df_G_taxo['sample'] == sample, 'taxoID']
        dfresult_taxoid_list = []
        for taxoid in taxoids:
            #print(taxoid)
            blast_result_df = blast_result_as_df(taxoid,sample,results_path)
            if not blast_result_df.empty:
                df_temp = pd.merge(df_G_taxo, blast_result_df, how='inner', left_on=['taxoID','sample'], right_on=['taxoID_kraken2','sample_kraken2'],left_index=False, right_index=False, sort=True,suffixes=('_x', '_y'), indicator=False)
                dfresult_taxoid_list.append(df_temp)
                #print(dfresult_taxoid_list)
        #print(dfresult_taxoid_list)    
        if dfresult_taxoid_list:
            dfresult_taxoid = pd.concat(dfresult_taxoid_list, ignore_index=True)
            dfresult_list.append(dfresult_taxoid)
            #print(dfresult_taxoid)
    dfresult = pd.concat(dfresult_list, ignore_index=True)
    
    # formatting the dfresult
    dfresult = format_dfresult(dfresult)
    
    dfresult = get_genus_taxID(dfresult)
    
    # comparing the names from the blast and kraken2 outputs and adding a column with the comparison result
    # this is not ideal as we can have true results that are not the best blast hit! I have to find a way to isolate first all higest blast hits and than the ture hits and see if hihgest blast hit is also highest true hit!
    dfresult = compare_names(dfresult)
    dfresult = compare_genus_taxid(dfresult)
    dfresult.to_csv(results_path+'kraken_blast_comparison.tsv', sep='\t', index=False, header=True)
    print(dfresult)
    # selecting the rows where the name comparison is True
    #dfresult_true = dfresult[dfresult.name_comparison == True].copy()
    
    # selecting the rows where the name comparison is True
    #dfresult_true = dfresult[dfresult.taxoid_comparison == True].copy()
    
    # selecting the rows where the name comparison is True or the taxoid comparison is True 
    dfresult_true = dfresult[(dfresult.taxoid_comparison == True) | (dfresult.name_comparison == True)]


    #print(dfresult_true)
    #dfresult_true.to_csv(results_path+'kraken_blast_comparison_true.tsv', sep='\t', index=False, header=True)
    
    # selecting the rows where the name comparison is True and the bitscore is the highest
    dfresult_true_bitscoremax = dfresult_true[dfresult_true.groupby(['sample','taxoID','name','read-count','read'])['bitscore'].transform('max') == dfresult_true['bitscore']]
    #print(dfresult_true_bitscoremax)
    #dfresult_true_bitscoremax.to_csv(results_path+'kraken_blast_comparison_true_highetscore.tsv', sep='\t', index=False, header=True)  
    dfresult_true_bitscoremax_concat = add_highest_bitscore_if_false(dfresult,dfresult_true_bitscoremax)   
    print(dfresult_true_bitscoremax_concat)
    
    dfresult_true_bitscoremax_concat = dfresult_true_bitscoremax_concat.sort_values(by=['sample', 'taxoID','read'])
    
    dfresult_true_bitscoremax_concat.to_csv(results_path+'kraken_blast_comparison_true_bitscoremax_plusfalsemax.tsv', sep='\t', index=False, header=True)
 
    

if __name__ == "__main__":
    main()
