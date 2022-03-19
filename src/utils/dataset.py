from typing import Any, Dict
from tqdm import tqdm

import torch
from torch.utils.data import Dataset
import gluonnlp as nlp

from torch.utils.data import DataLoader, RandomSampler, DistributedSampler, random_split


class MakeDataSet(Dataset):
    def __init__(
        self, dataset: str = None, tokenizer: Any = None, max_length: int = 500
    ):

        self.dataset = dataset
        rows, cols = self.dataset.shape

        self.processed_dataset = []

        transform = nlp.data.BERTSentenceTransform(
            tokenizer=tokenizer, max_seq_length=max_length, pad=True, pair=False
        )

        def gen_attention_mask(token_ids, valid_length):
            attention_mask = torch.zeros_like(token_ids)
            for i in range(valid_length.item()):
                attention_mask[i] = 1
            return attention_mask

        for line in tqdm(range(rows), desc="Processing"):
            comment = self.dataset["comment"][line]
            label = self.dataset["label"][line]

            processed_data = {}
            try:
                encoded_data = transform([comment])
            except:
                encoded_data = transform([" "])
            processed_data["input_ids"] = torch.LongTensor(encoded_data[0])
            processed_data["attention_mask"] = gen_attention_mask(
                processed_data["input_ids"], encoded_data[1]
            )

            processed_data["label"] = torch.LongTensor([label])

            self.processed_dataset.append(processed_data)

    def __len__(self):
        return len(self.processed_dataset)

    def __getitem__(self, idx: int = None):
        return self.processed_dataset[idx]


def get_data_loader(dataset, num_workers=4, batch_size=32, shuffle=True):
    train_sampler = torch.utils.data.distributed.DistributedSampler(dataset)
    data_loader = torch.utils.data.DataLoader(
        dataset=dataset,
        batch_size=batch_size,
        pin_memory=True,
        num_workers=num_workers,
        shuffle=shuffle,
        sampler=train_sampler,
    )
    return data_loader
