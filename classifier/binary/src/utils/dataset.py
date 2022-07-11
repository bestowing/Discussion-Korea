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
        label = torch.tensor(self.label[idx])
        return (sent, label)
    
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