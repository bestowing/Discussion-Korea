import os
import os.path as p
from tqdm import tqdm
import json
import pickle 
import pandas as pd
import zipfile
from sklearn.model_selection import train_test_split

def load_zip_file(src_path):
    folder = ['Training', 'Validation']
    kind = ['법률','사설','신문기사']
    for num, fl in enumerate(folder):
        file_list = os.listdir(p.join(src_path, f"{fl}"))
        my_zip = [zipfile.ZipFile(p.join(src_path, f"{fl}/{zip}")) for zip in file_list]
        for idx, z_file in enumerate(my_zip):
            os.makedirs(f'./{kind[idx]}', exist_ok=True)
            z_file.extractall(f"./{kind[idx]}")
    print("Finish extract zip file")
    

# documents -> list({text[[sentence dict(index, sentence)],...],extractive:[],abstractive:[]})
def load_json_file(json_path):
    with open(json_path, 'r') as f:
        json_data = json.load(f)['documents']
        texts = []
        extract_label = []
        abstract_label = []
        for data in tqdm(json_data):
            text = data["text"]
            extractive = data["extractive"]
            extract = []
            abstractive = data["abstractive"]
            full_text = ""
            for sents in text:
                all_sent = [idx['sentence'] for idx in sents]
                extract += [idx['sentence'] for idx in sents if idx['index'] in extractive]
                for sent in all_sent:
                    full_text += sent + " "
            extractive = ""
            for sent in extract:
                extractive += sent + " "
            texts.append(full_text)
            extract_label.append(extract)
            abstract_label.append(abstractive[0])
        df = pd.DataFrame()
        df['news'] = texts
        # df['extractive_label'] = extract_label
        df['summary'] = abstract_label
        return df

def make_dataframe(src_path):
    """
    Funct :
        - Concat all data and split train/test/valid set
    """
    load_zip_file(p.join(src_path,"aihub")) 
       
    law_path_train = p.join(src_path, "법률/train_original.json")
    law_path_valid = p.join(src_path, "법률/valid_original.json")
    
    article_path_train = p.join(src_path, "사설/train_original.json")
    article_path_valid = p.join(src_path, "사설/valid_original.json")
    
    news_path_train = p.join(src_path, "신문기사/train_original.json")
    news_path_valid = p.join(src_path, "신문기사/valid_original.json")
    
    df1 = load_json_file(law_path_train)
    df2 = load_json_file(law_path_valid)

    df3 = load_json_file(article_path_train)
    df4 = load_json_file(article_path_valid)

    df5 = load_json_file(news_path_train)
    df6 = load_json_file(news_path_valid)
    
    data_law = pd.concat([df1, df2])
    data_article = pd.concat([df3, df4])
    data_news = pd.concat([df5, df6])
    
    all_data = pd.concat([data_law, data_article])
    all_data = pd.concat([all_data, data_news])
    
    train_df, test_df = train_test_split(all_data, test_size=0.2)
    test_df, valid_df = train_test_split(test_df, test_size=0.5)
    
    os.makedirs(f'./processed', exist_ok=True)

    for df, name in zip((train_df, valid_df, test_df), ("train","valid","test")):
        df = df.reset_index(drop=True)
        df.to_csv(p.join(src_path, f"processed/{name}.csv"), sep="\t", na_rep="")
        
    for df, name in zip((data_law, data_article, data_news), ("law","article","news")):
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
    

make_dataframe(os.getcwd())