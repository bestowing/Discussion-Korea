from multiprocessing import pool
import torch
import torch.nn as nn
import torch.nn.functional as F
from transformers import AutoModel, AutoConfig, DistilBertModel
from transformers import logging 

class RobertaModel(nn.Module):
    """
    Roberta Model for classification
    """
    def __init__(self, checkpoint, num_labels):
        super(RobertaModel, self).__init__()
        self.num_labels = num_labels
        
        self.model = model = AutoModel.from_pretrained(checkpoint, config=AutoConfig.from_pretrained(checkpoint, output_attentions=True,output_hidden_states=True))
        self.dropout = nn.Dropout(0.1)
        self.classifier = nn.Linear(768, self.num_labels)
        
    def forward(self, input_ids=None, attention_maks=None, labels=None, test=False):
        outputs = self.model(input_ids=input_ids, attention_mask=attention_maks)
        # outputs.hidden_states (batch_size, length, hidden_size=768)
        
        pooled_output = torch.cat(tuple([outputs.hidden_states[i] for i in [-4, -3, -2, -1]]), dim=-2)
        pooled_output = torch.max(pooled_output, dim=-2).values
        pooled_output = pooled_output[:,:]
        pooled_output = self.dropout(pooled_output)
        logits = self.classifier(pooled_output.view(-1,768))
        
        loss = None
        if labels is not None:
            criterion = nn.CrossEntropyLoss()
            loss = criterion(logits.view(-1,self.num_labels), labels)
        
        return logits, loss
    
class MultiLabelClassifier(nn.Module):
    """
    Roberta Model for multi label classification
    """
    def __init__(self, checkpoint):
        super(MultiLabelClassifier, self).__init__()
        
        self.model = model = AutoModel.from_pretrained(checkpoint, config=AutoConfig.from_pretrained(checkpoint, output_attentions=True,output_hidden_states=True))
        self.dropout = nn.Dropout(0.1)
        self.classifier1 = nn.Linear(768, 10)
        self.classifier2 = nn.Linear(778, 2)
        
    def forward(self, input_ids=None, attention_maks=None, labels=None, device=None):
        logging.set_verbosity_warning() 
        outputs = self.model(input_ids=input_ids, attention_mask=attention_maks)
        # outputs.hidden_states (batch_size, length, hidden_size=768)
        pooled_output = torch.cat(tuple([outputs.hidden_states[i] for i in [-4, -3, -2, -1]]), dim=-2)
        pooled_output = torch.max(pooled_output, dim=-2).values
        pooled_output = pooled_output[:,:]
        pooled_output = self.dropout(pooled_output)
        logits = self.classifier1(pooled_output.view(-1,768))
        
        # (batch_size, length, number of label)
        # (batch_size, length, hidden_size)
        connection = torch.cat(tuple([pooled_output, logits]), dim=-1)
        output = self.classifier2(connection.view(-1,778))
        
        kind_loss = None
        toxic_loss = None
        
        #print(toxic_labels)
        if labels is not None:
            kind_labels = labels[:,(0,1,2,3,4,5,6,7,8,10)]
            toxic_labels = labels[:,-2].type(torch.LongTensor).to(device) 
            criterion = nn.CrossEntropyLoss()
            kind_loss = criterion(logits.view(-1,10), kind_labels)
            toxic_loss = criterion(output.view(-1,2), toxic_labels)
        
        return logits, output, kind_loss, toxic_loss
    
class StudentModel(nn.Module):
    """
    Student Model for classification
    """
    def __init__(self, num_labels):
        super(StudentModel, self).__init__()
        self.num_labels = num_labels
        
        self.model = model = DistilBertModel.from_pretrained('monologg/distilkobert')
        self.dropout = nn.Dropout(0.1)
        self.classifier = nn.Linear(768, num_labels)
        
    def forward(self, input_ids=None, attention_maks=None):
        outputs = self.model(input_ids=input_ids, attention_mask=attention_maks)
        outputs = self.dropout(outputs[0])
        logits = self.classifier(outputs[:,0,:].view(-1,768))

        return logits