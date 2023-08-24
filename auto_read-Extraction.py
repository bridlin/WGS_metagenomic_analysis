import pandas as pd
import os
import sys
from extract_kraken_reads import run_extraction  as KT_run_extraction
from dataclasses import dataclass

#### Methodes ####

def get_sample_names(kraken_file_path):
    
    sample_names = []
    for root, dirs, files in os.walk(kraken_file_path):
        for names in files:
            #print(files)
            #print(names)
            if os.path.splitext(names)[1] == ".k2report":
                 sample_names.append(os.path.splitext(names)[0])
    return sample_names    

def strip_samplenames(sample_name,kraken_file_path):
    substring = kraken_file_path.split('/')
    striped_name = sample_name.split(substring[3])
    return striped_name[0]

def read_report(report, column_names):
    df_report = pd.read_table(report, names=column_names)
    return df_report
 

def get_G_taxoIDs(df, sample): # returns a dataframe with taxoID, patho_name, reads and sample for all Genuses
    df_filtered = df.loc[df['rank'] == 'G' ]
    #print(df_filtered)
    df_filtered = df_filtered[df_filtered['sci_name'].str.contains('Homo') == False]
    #print(df_filtered)
    df_taxoIDs = pd.DataFrame()
    df_taxoIDs['taxoID'] = df_filtered['taxoID']
    df_taxoIDs['name'] = df_filtered['sci_name']
    df_taxoIDs['reads'] = df_filtered['num_frag']
    df_taxoIDs['sample'] = sample
    return df_taxoIDs

def make_taxoID_sample_dict(df, sample_names): # returns a config file for the read-extraction script
    taxo_per_sample = {}
    for sample  in sample_names:
        #print(sample)
        taxoIDs= []
        for index in df.index:
            if df['sample'].values[index] == sample :
                taxoID = df['taxoID'].values[index]
                taxoIDs.append(taxoID)   

        taxo_per_sample[sample] = taxoIDs
    #print(taxo_per_sample)
    return taxo_per_sample
    
def make_config(dict):   
    f= open("config_readextraction.txt","w+")
    for keys in dict:
        #print(keys)
        #print(taxo_per_sample[keys])
        f.write("\n" + keys + '=('  )
        for item in dict[keys]:
            #print(item)
            f.write('"' + str(item) + '" ')
        f.write(')')
    f.close()
    
    


# def make_Args(df,sample_names):
#     for sample in sample_names:





#### classes ####

@dataclass
class Args():
    kraken_file: str
    seq_file1: str
    seq_file2: str
    taxid: list[int]
    report_file: str
    output_file: str
    output_file2: str
    parents: bool = False
    exclude: bool = False
    children: bool = True
    max_reads: int = 100000000

    

#### Main ####
def main():
    read_file_path = '/fastq_run9/'
    kraken_file_path = '/kraken2-results_run9_5prime-trimmed/EuPathDB48/'                                        # file path to kraken_results
    print(get_sample_names(kraken_file_path))
    

    column_names = ['perc_frag', 'num_frag', 'num_frag_taxo', 'x' , 'y' , 'rank' , 'taxoID', 'sci_name']    # column names for Kraken2 reports
    
    df_taxoIDs_all = pd.DataFrame(columns=['sample' ,'taxoID', 'name', 'reads'])                            # empty df to be filled 
    
    for root, dirs, files in os.walk(kraken_file_path): 
        for file in files: 
            if os.path.splitext(file)[1] == ".k2report":                                                    # identification of the Kraken2 reports that have to be read
                report = root + file
                sample = os.path.splitext(file)[0]
                df_filtered = get_G_taxoIDs(read_report(report, column_names),sample)  
                df_taxoIDs_all = pd.concat([df_taxoIDs_all, df_filtered], ignore_index=True)
        print(df_taxoIDs_all)
        df_taxoIDs_all.to_csv(root+"G_TaxoIDs_per_sample.tsv", sep="\t")
    dict_taxo_per_sample = make_taxoID_sample_dict(df_taxoIDs_all,get_sample_names(kraken_file_path))
    print(dict_taxo_per_sample)


    #make_config(dict_taxo_per_sample)
    
    for sample in get_sample_names(kraken_file_path):
        for keys in dict_taxo_per_sample:
            if sample == keys:
                for item in dict_taxo_per_sample[keys]:
                    striped_sample = (strip_samplenames(sample, kraken_file_path))
                    print(striped_sample)
                    kraken_file = kraken_file_path + sample + '.kraken2'
                    seq_file1 = read_file_path + striped_sample + 'nonhuman_reads_5trimmed.1.fastq'
                    seq_file2 = read_file_path + striped_sample + 'nonhuman_reads_5trimmed.2.fastq'
                    report_file = kraken_file_path + sample + '.k2report'
                    output_file = sample + '.tid' + str(item) + '.1.fa'
                    output_file2 = sample + '.tid' + str(item) + '.2.fa'
                    taxid = [item]
                    print(kraken_file)
                    print(seq_file1)
                    print(seq_file2)
                    print(report_file)
                    print(output_file)
                    print(output_file2)
                    print(taxid)
                    args = Args(kraken_file, \
                    seq_file1, \
                    seq_file2, \
                    taxid, \
                    report_file, \
                    output_file, \
                    output_file2
                    )
                    print(args)
                    KT_run_extraction(args)




if __name__ == "__main__":
    main()
