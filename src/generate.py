from simplejson import OrderedDict
from .train import generate_result
from transformers import AutoTokenizer
from .model import RobertaModel
import torch
import json
from collections import OrderedDict

ckpt = "./ckpt/basemodel.pt"
tokenizer = AutoTokenizer.from_pretrained("klue/roberta-base")

device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")

print(f"-- Running on {device}. --")

model = RobertaModel("klue/roberta-base", 2)
model.load_state_dict(torch.load(ckpt, map_location=torch.device('cpu'))['model_state_dict'])

n = 1
while(True):
    data = OrderedDict()
    input_sent = input("Type the sentence : ")
    if input_sent == "exit":
        break
    data['input'] = input_sent
    data['result'] = generate_result(model, input_sent, tokenizer, device)
    
    with open(str(n)+"th data.json","w",encoding="utf-8") as make_file:
        json.dump(data, make_file,  ensure_ascii=False, indent="\t")
    n += 1