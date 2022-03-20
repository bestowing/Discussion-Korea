import torch
import torch.nn as nn
from transformers import AutoModel, AutoConfig, DistilBertModel, BertModel


class DistilBert(nn.Module):
    """
    Roberta Model for classification
    """
    def __init__(self, checkpoint, num_labels):
        super(DistilBert, self).__init__()
        self.num_labels = num_labels
        
        self.model = model = DistilBertModel.from_pretrained(checkpoint, config=AutoConfig.from_pretrained(checkpoint, output_attentions=True,output_hidden_states=True))
        self.dropout = nn.Dropout(0.1)
        self.classifier = nn.Linear(768, num_labels)
        
    def forward(self, input_ids=None, attention_maks=None, labels=None):
        outputs = self.model(input_ids=input_ids, attention_mask=attention_maks)
        outputs = self.dropout(outputs[0])
        logits = self.classifier(outputs[:,0,:].view(-1,768))
        
        loss = None
        if labels is not None:
            criterion = nn.CrossEntropyLoss()
            loss = criterion(logits.view(-1,self.num_labels), labels.view(-1))
        return logits, loss



class KoBert(nn.Module):
    """
    Roberta Model for classification
    """
    def __init__(self, checkpoint, num_labels):
        super(KoBert, self).__init__()
        self.num_labels = num_labels
    
        self.model = model = BertModel.from_pretrained(checkpoint, config=AutoConfig.from_pretrained(checkpoint, output_attentions=True,output_hidden_states=True))
        self.dropout = nn.Dropout(0.1)
        self.classifier = nn.Linear(768, num_labels)
    
    def forward(self, input_ids=None, attention_maks=None, labels=None):
        outputs = self.model(input_ids=input_ids, attention_mask=attention_maks)
        outputs = self.dropout(outputs[0])
        logits = self.classifier(outputs[:,0,:].view(-1,768))
    
        loss = None
        if labels is not None:
            criterion = nn.CrossEntropyLoss()
            loss = criterion(logits.view(-1,self.num_labels), labels.view(-1))
        return logits, loss



class RobertaModel(nn.Module):
    """
    Roberta Model for classification
    """
    def __init__(self, checkpoint, num_labels):
        super(RobertaModel, self).__init__()
        self.num_labels = num_labels
        
        self.model = model = AutoModel.from_pretrained(checkpoint, config=AutoConfig.from_pretrained(checkpoint, output_attentions=True,output_hidden_states=True))
        self.dropout = nn.Dropout(0.1)
        self.classifier = nn.Linear(768, num_labels)
        
    def forward(self, input_ids=None, attention_maks=None, labels=None):
        outputs = self.model(input_ids=input_ids, attention_mask=attention_maks)
        outputs = self.dropout(outputs[0])
        logits = self.classifier(outputs[:,0,:].view(-1,768))
        
        loss = None
        if labels is not None:
            criterion = nn.CrossEntropyLoss()
            loss = criterion(logits.view(-1,self.num_labels), labels.view(-1))
        return logits, loss