import pandas as pd
import os
import sys
from dataclasses import dataclass
from auto_read-Extraction import get_sample_names
from auto_read-Extraction import strip_samplenames


#### Methodes ####

def read_G_taxoIDs(G_taxoIDs, column_names):
    df_report = pd.read_table(report, names=column_names)
    return df_report