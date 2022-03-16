import os
import os.path as p
import pickle 
import pandas as pd
from sklearn.model_selection import train_test_split

def load_txt_data(txt_path, sep='|'):
    """
    Funct:
        - Load text file of toxic comments
        - Simple pre-processing
    """
    with open(txt_path, 'r') as f:
        lines = f.readlines()
    lines = [line.strip() for line in lines]
    sent = []
    label = []
    for line in lines:
        ls = line.split(sep)
        sent.append(ls[0])
        label.append(ls[1])
    df = pd.DataFrame()
    df['comment'] = sent
    df['label'] = label
    y = label
    return df, y 

def load_tsv_data(tsv_path):
    """
    Funct:
        - Load table file of toxic comments
        - Simple pre-processing
    """
    table = pd.read_table(tsv_path)
    # If you want to make a strong masking model, classify offensive to normal
    #table.loc[(table.hate == 'offensive'), 'hate'] = 0
    #table.loc[(table.hate == 'hate'), 'hate'] = 1
    table.loc[(table.hate != 'none'), 'hate'] = 1
    table.loc[(table.hate == 'none'), 'hate'] = 0
    sent = list(table['comments'])
    label = list(table['hate'])
    df = pd.DataFrame()
    df['comment'] = sent
    df['label'] = label
    y = label
    return df, y

def make_dataframe(src_path, dst_path):
    """
    Funct :
        - Concat all data and split train/test/valid set
    """
    txt_path = p.join(src_path, "raw/dataset.txt")
    tsv_dev_path = p.join(src_path, "raw/dev.tsv")
    tsv_train_path = p.join(src_path, "raw/train.tsv")
    
    df1,  y1 = load_txt_data(txt_path)
    df2,  y2 = load_tsv_data(tsv_dev_path)
    df3,  y3 = load_tsv_data(tsv_train_path)
    
    data = pd.concat([df1, df2])
    data = pd.concat([data, df3])
    
    label = y1 + y2 + y3
    
    train_df, temp_df , y, temp_y = train_test_split(data, label, test_size=0.2, stratify=label)
    test_df, valid_df , test_y, valid_y = train_test_split(temp_df, temp_y, test_size=0.5, stratify=temp_y)
    
    for df, name in zip((train_df, valid_df, test_df), ("train","valid","test")):
        df = df.reset_index(drop=True)
        df.to_csv(p.join(src_path, f"processed/{name}.csv"), sep="\t", na_rep="")
    

def get_dataframe(src_path):
    """
    Funct :
        - Get dataframe
    """
    dfs = []
    for name in ("train", "valid", "test"):
        df = pd.read_csv(p.join(src_path, f"{name}.csv"), sep='\t')
        df = df.dropna(axis=0)
        dfs.append(df)

    return dfs
    
    
        

