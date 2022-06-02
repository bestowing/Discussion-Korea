from typing_extensions import Self
import pandas as pd
import numpy as np
import torch
from torch.utils.data import Dataset, DataLoader
from transformers import AutoTokenizer

class MakeDataset(Dataset):
    def __init__(self, df, args, tokenizer):
        self.df = df
        self.tokenizer = tokenizer
        self.sent = [self.tokenizer(token, padding="max_length", truncation=True, max_length=512).input_ids for token in self.df['comment'].to_list()]
        self.label = list(self.df['label'])
        
    def __len__(self):
        return len(self.df)
    
    def __getitem__(self, idx):
        sent = torch.tensor(self.sent[idx])
        label = torch.Tensor(self.label[idx])
        return (sent, label)
    
class MakeMultiDataset(Dataset):
    def __init__(self, sentence, label, args, tokenizer):
        self.sentence = sentence
        self.label = label
        self.tokenizer = tokenizer
        self.sent = [self.tokenizer(token, padding="max_length", truncation=True, max_length=512).input_ids for token in self.sentence]
    def __len__(self):
        return len(self.sentence)
    
    def __getitem__(self, idx):
        sent = torch.tensor(self.sent[idx])
        label = torch.Tensor(self.label[idx])
        return (sent, label)

    
class MakeMultiDataset_diff(Dataset):
    def __init__(self, sentence, kind_label, toxic_label, args, tokenizer):
        self.sentence = sentence
        self.kind_label = kind_label
        self.toxic_label = toxic_label
        self.tokenizer = tokenizer
        self.sent = [self.tokenizer(token, padding="max_length", truncation=True, max_length=512).input_ids for token in self.sentence]
    def __len__(self):
        return len(self.sentence)
    
    def __getitem__(self, idx):
        sent = torch.tensor(self.sent[idx])
        kind_label = torch.tensor(self.kind_label[idx])
        toxic_label = torch.Tensor(self.toxic_label[idx])
        return (sent, [kind_label, toxic_label])
    
def load_data_loader(ds, batch_size, shuffle=False):
    """
    Funct :
        - Data Loader for training
        - if you want to get randomize dataset -> set shuffle True
    """
    data_loader = DataLoader(
        ds,
        batch_size = batch_size,
        shuffle = shuffle
        
    )
    return data_loader