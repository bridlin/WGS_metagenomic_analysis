import pandas as pd
import os


#### Methodes ####

def get_sample_names(file_path):
    sample_names = []
    for root, dirs, files in os.walk(file_path):
        for names in files:
            if os.path.splitext(names)[1] == ".k2report":
                 sample_names.append(os.path.splitext(names)[0])
    return sample_names    


def read_report(report, column_names):
    df_report = pd.read_table(report, names=column_names)
    return(df_report)
 

def get_G_taxoIDs(df, sample): # returns a dataframe with taxoID, patho_name, reads and sample for all Genuses
    df_filtered = df.loc[df['rank'] == 'G' ]
    df_taxoIDs = pd.DataFrame()
    df_taxoIDs['taxoID'] = df_filtered['taxoID']
    df_taxoIDs['name'] = df_filtered['sci_name']
    df_taxoIDs['reads'] = df_filtered['num_frag']
    df_taxoIDs['sample'] = sample
    return(df_taxoIDs)

def make_config(df, sample_names): # returns a config file for the read-extraction script
    f= open("config_readextraction.txt","w+")
    taxo_per_sample = {}
    for sample  in sample_names:
        #print(sample)
        taxoIDs= []
        for ind in df.index:
            if df['sample'].values[ind] == sample :
                taxoID = df['taxoID'].values[ind]
                taxoIDs.append(taxoID)   

        taxo_per_sample[sample] = taxoIDs
    #print(taxo_per_sample)
    for keys in taxo_per_sample:
        print(keys)
        print(taxo_per_sample[keys])
        f.write("\n" + keys + '= ('  )
        for  item in taxo_per_sample[keys]:
            print(item)
            f.write('"' + str(item) + '" ')
        f.write(')')
    f.close()
    


def main():
    file_path = '../kraken2-results_run11_5prime-trimmed/PlusPF/'                                        # file path to kraken_results
    print(get_sample_names(file_path))
    column_names = ['perc_frag', 'num_frag', 'num_frag_taxo', 'x' , 'y' , 'rank' , 'taxoID', 'sci_name']    # column names for Kraken2 reports
    
    df_taxoIDs_all = pd.DataFrame(columns=['sample' ,'taxoID', 'name', 'reads'])
    
    for root, dirs, files in os.walk(file_path):
        for file in files: 
            if os.path.splitext(file)[1] == ".k2report":                                                    # identification of the Kraken2 reports that have to be read
                report = root + file
                sample = os.path.splitext(file)[0]
                df_filtered = get_G_taxoIDs(read_report(report, column_names),sample)  
                df_taxoIDs_all = pd.concat([df_taxoIDs_all, df_filtered], ignore_index=True)
    #print(df_taxoIDs_all)
    df_taxoIDs_all.to_csv("TaxoIDs_per_sample.tsv", sep="\t")
    make_config(df_taxoIDs_all,get_sample_names(file_path))



if __name__ == "__main__":
    main()
