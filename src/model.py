from typing import Any, Tuple, Dict, Union, List, Optional, Sequence

import torch.nn as nn
from transformers.models.bert.modeling_bert import BertModel


class KoBertClassficationModel(nn.Module):
    def __init__(
        self,
        lm_model: BertModel = None,
        num_classes: int = 2,
        drop_rate=0.3,
        device="cuda",
    ):
        super().__init__()
        self.num_classes = num_classes

        self.text_embedding = lm_model
        self.classifier_hidden_size = self.text_embedding.config.hidden_size
        self.dropout = nn.Dropout(p=drop_rate)

        self.classifier = nn.Linear(self.classifier_hidden_size, self.num_classes)

        self.device = device

    def forward(self, batch: Dict = None) -> float:
        text_embedded = self.text_embedding(
            batch["input_ids"].to(self.device),
            token_type_ids=None,
            attention_mask=batch["attention_mask"].to(self.device),
        )
        text_embedded = text_embedded[1]
        text_embedded = self.dropout(text_embedded)

        logits = self.classifier(text_embedded)

        return logits
