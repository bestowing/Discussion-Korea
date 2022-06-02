import torch
from kobart import get_kobart_tokenizer
from transformers.models.bart import BartForConditionalGeneration

from transformers import PreTrainedTokenizerFast

import pandas as pd

import pprint

import time


def load_model(model_dir=None):
    model = BartForConditionalGeneration.from_pretrained(model_dir)#'./kobart_summary2'
    return model


device = 'cuda' if torch.cuda.is_available() else "cpu"

tokenizer1 = PreTrainedTokenizerFast.from_pretrained(
    'digit82/kobart-summarization')
model1 = BartForConditionalGeneration.from_pretrained(
    'digit82/kobart-summarization').to(device)


# model2 = load_model('./kobart_summary2').to(device)
model4 = load_model(f'./kobart_summary_version4_e23').to(device)#현재까지 가장 잘하는 듯함
model5 = load_model(f'./kobart_summary_version4_e29').to(device)
model6 = load_model(f'./kobart_summary_version4_e39').to(device)
model7 = load_model(f'./kobart_summary_version4_e49').to(device)
model_list = [model4, model5, model6, model7]
tokenizer2 = get_kobart_tokenizer()


def get_summary(text, model, tokenizer):
    raw_input_ids = tokenizer.encode(text)
    input_ids = [tokenizer.bos_token_id] + \
        raw_input_ids + [tokenizer.eos_token_id]

    summary_ids = model.generate(torch.tensor(
        [input_ids], device=device),  num_beams=50,no_repeat_ngram_size = 2 ,max_length=1000,  eos_token_id=1)
    result = tokenizer.decode(
        summary_ids.squeeze().tolist(), skip_special_tokens=True)

    return result


width = 60
origin_text = pd.read_csv('data/dpn_final3.csv')
for i in range(len(model_list)):
    origin_text[f'summary{i}'] = 'no_summary'
    origin_text[f'score{i}'] = 0
for idx in range(len(origin_text)):
    try:
        if 500 < len(origin_text['text'][idx])<2000:
            for i, model in enumerate(model_list):
                summary = get_summary(origin_text['text'][idx], model, tokenizer2)
                origin_text[f'summary{i}'][idx] = summary
        else:
            print(f'######## idx:{idx} length boundary 500 ~ 2000 ########')
    except:
        print(f'######## idx:{idx} Can not summarize! ########')

drop_idx_list = origin_text[origin_text['summary0']=='no_summary'].index
origin_text_final = origin_text.drop(drop_idx_list)
origin_text.to_csv('data/origin_summary_metric.csv')



