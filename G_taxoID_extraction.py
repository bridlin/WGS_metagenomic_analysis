#import pandas as pd
import os





def get_sample_names(file_path):
    sample_names = []
    for root, dirs, files in os.walk(file_path):
        for names in files:
            if os.path.splitext(names)[1] == ".k2report":
                 sample_names.append(os.path.splitext(names)[0])
    return sample_names    
       
 
def main():
    file_path = '../../kraken2-results_run11_5prime-trimmed/PlusPF/'  # file path
    print(get_sample_names(file_path))

if __name__ == "__main__":
    main()
