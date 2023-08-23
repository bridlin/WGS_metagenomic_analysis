import pandas as pd
import os
import sys

#### Methodes ####

def get_sample_names(file_path):
    sample_names = []
    for root, dirs, files in os.walk(file_path):
        for names in files:
            #print(files)
            #print(names)
            if os.path.splitext(names)[1] == ".k2report":
                 sample_names.append(os.path.splitext(names)[0])
    return sample_names    


def read_report(report, column_names):
    df_report = pd.read_table(report, names=column_names)
    return(df_report)
 

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
    return(df_taxoIDs)

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
    
    
def run_script_redextraction(dict,):
    for sample, taxoIDs in dict.items():
        for item in taxoIDs:
            print(sample)
            print(item)
#         sys.argv = ["-k $output_dir/$kraken_output_dir/$sample\.kraken2", "arg2"]
#         exec(open(filepath).read())

# KrakenTools-master/extract_kraken_reads.py -k $output_dir/$kraken_output_dir/$sample\.kraken2 --include-children -s $read_directory/$sample\nonhuman_reads.1.fastq -s2 $read_directory/$sample\nonhuman_reads.2.fastq -t $id\  -r $output_dir/$kraken_output_dir/$sample\.k2report -o $sample\.tid$id\.1.fa  -o2 $sample\.tid$id\.2.fa 




def main():
    file_path = '../../kraken2-results_run9_5prime-trimmed/PlusPF/'                                        # file path to kraken_results
    print(get_sample_names(file_path))
    column_names = ['perc_frag', 'num_frag', 'num_frag_taxo', 'x' , 'y' , 'rank' , 'taxoID', 'sci_name']    # column names for Kraken2 reports
    
    df_taxoIDs_all = pd.DataFrame(columns=['sample' ,'taxoID', 'name', 'reads'])                            # empty df to be filled 
    
    for root, dirs, files in os.walk(file_path): 
        for file in files: 
            if os.path.splitext(file)[1] == ".k2report":                                                    # identification of the Kraken2 reports that have to be read
                report = root + file
                sample = os.path.splitext(file)[0]
                df_filtered = get_G_taxoIDs(read_report(report, column_names),sample)  
                df_taxoIDs_all = pd.concat([df_taxoIDs_all, df_filtered], ignore_index=True)
        print(df_taxoIDs_all)
        df_taxoIDs_all.to_csv(root+"G_TaxoIDs_per_sample.tsv", sep="\t")
    dict_taxo_per_sample = make_taxoID_sample_dict(df_taxoIDs_all,get_sample_names(file_path))
    print(dict_taxo_per_sample)
    make_config(dict_taxo_per_sample)
    #run_script_redextraction(dict_taxo_per_sample)




if __name__ == "__main__":
    main()
