import pandas as pd
import os





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
 




def get_G_taxoIDs(df, sample):
    df_filtered = df.loc[df['rank'] == 'G' ]
    df_taxoIDs = pd.DataFrame()
    #df_taxoIDs['taxoID', 'name', 'reads'] = df['taxoID', 'sci_name', 'num_frag' ]
    
    df_taxoIDs['taxoID'] = df_filtered['taxoID']
    df_taxoIDs['name'] = df_filtered['sci_name']
    df_taxoIDs['reads'] = df_filtered['num_frag']
    df_taxoIDs['sample'] = sample
    return(df_taxoIDs)


    


def main():
    file_path = '../../kraken2-results_run11_5prime-trimmed/PlusPF/'                                        # file path to kraken_results
    print(get_sample_names(file_path))
    column_names = ['perc_frag', 'num_frag', 'num_frag_taxo', 'x' , 'y' , 'rank' , 'taxoID', 'sci_name']    # column names for Kraken2 reports
    
    df_taxoIDs_all = pd.DataFrame(columns=['sample' ,'taxoID', 'name', 'reads'])
    
    for root, dirs, files in os.walk(file_path):
        for file in files: 
            if os.path.splitext(file)[1] == ".k2report":                                                    # identification of the Kraken2 reports that have to be read
                report = root + file
                sample = os.path.splitext(file)[0]
                df_filtered = get_G_taxoIDs(read_report(report, column_names),sample)
                #print(df_filtered)
                pd.concat([df_taxoIDs_all, df_filtered], keys=['sample' ,'taxoID', 'name', 'reads'])       
                df_taxoIDs_all = pd.concat([df_taxoIDs_all, df_filtered])
    print(df_taxoIDs_all)





if __name__ == "__main__":
    main()
