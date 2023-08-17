import pandas as pd
import os





def get_sample_names(file_path):
    sample_names = []
    for root, dirs, files in os.walk(file_path):
        for names in files:
            if os.path.splitext(names)[1] == ".k2report":
                 sample_names.append(os.path.splitext(names)[0])
    return sample_names    


def read_report(report):
    df_report = pd.read_table(report)
    return(df_report)
 
def main():
    file_path = '../../kraken2-results_run11_5prime-trimmed/PlusPF/'  # file path
    print(get_sample_names(file_path))

    report = '../../kraken2-results_run11_5prime-trimmed/PlusPF/MC6A_S1_.k2report'
    print(read_report(report))


if __name__ == "__main__":
    main()
