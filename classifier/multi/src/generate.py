from simplejson import OrderedDict
from .train import generate_multi_result
from transformers import AutoTokenizer
from .model import RobertaModel, MultiLabelClassifier
import torch
import json
from collections import OrderedDict
from transformers import logging

def generate():
    logging.set_verbosity_error()
    
    ckpt = "./ckpt/multi-base3.pt"
    
    tokenizer = AutoTokenizer.from_pretrained("klue/roberta-base")    
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

    model = RobertaModel("klue/roberta-base", 11)
    model.load_state_dict(torch.load(ckpt)['model_state_dict'])

    n = 1
    while(True):
        data = OrderedDict()
        input_sent = input("Type the sentence : ")
        if input_sent == "exit":
            break
        
        
        data['input'] = input_sent
        data['result'] = generate_multi_result(model, input_sent, tokenizer, device)
        
        
        with open(str(n)+"th data.json","w",encoding="utf-8") as make_file:
            json.dump(data, make_file,  ensure_ascii=False, indent="\t")
        n += 1
        
if __name__ == "__main__":
    generate()