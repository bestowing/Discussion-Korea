# KoBART-summarization for debating text

## Load KoBART
- huggingface.co에 있는 binary를 활용
  - https://huggingface.co/gogamza/kobart-base-v1

## Download binary
```python
import torch
from transformers import PreTrainedTokenizerFast
from transformers import BartForConditionalGeneration

tokenizer = PreTrainedTokenizerFast.from_pretrained('digit82/kobart-summarization')
model = BartForConditionalGeneration.from_pretrained('digit82/kobart-summarization')

text = text.replace('\n', ' ')

raw_input_ids = tokenizer.encode(text)
input_ids = [tokenizer.bos_token_id] + raw_input_ids + [tokenizer.eos_token_id]

summary_ids = model.generate(torch.tensor([input_ids]),  num_beams=4,  max_length=512,  eos_token_id=1)
tokenizer.decode(summary_ids.squeeze().tolist(), skip_special_tokens=True)


```
## Requirements
```
pytorch>=1.10.0
transformers==4.16.2
pytorch-lightning==1.5.10
streamlit==1.2.0
```
## Fine-tuning Datasets
- [Dacon 한국어 문서 생성요약 AI 경진대회](https://dacon.io/competitions/official/235673/overview/)
- [AIHub 문서요약 텍스트](https://aihub.or.kr/aidata/8054)

## Data structure
- 학습 데이터에서 임의로 Train / Test 데이터를 생성함
- 데이터 탐색에 용이하게 tsv 형태로 데이터를 변환함
- Data 구조
    - Train Data : 34,242
    - Test Data : 8,501
- default로 data/train.tsv, data/test.tsv 형태로 저장함
  
 

| news  | summary |
|-------|--------:|
| 뉴스원문| 요약문 |  


## How to Train
- KoBART summarization fine-tuning
```bash
pip install -r requirements.txt

[use gpu]
python train.py  --gradient_clip_val 1.0  \
                 --max_epochs 50 \
                 --default_root_dir logs \
                 --gpus 1 \
                 --batch_size 4 \
                 --num_workers 4

[use gpu]
python train.py  --gradient_clip_val 1.0  \
                 --max_epochs 50 \
                 --default_root_dir logs \
                 --strategy ddp \
                 --gpus 2 \
                 --batch_size 4 \
                 --num_workers 4

[use cpu]
python train.py  --gradient_clip_val 1.0  \
                 --max_epochs 50 \
                 --default_root_dir logs \
                 --strategy ddp \
                 --batch_size 4 \
                 --num_workers 4
```
## Generation Sample
| ||Text|
|-------|:--------|:--------|
|1|Label|태왕의 '성당 태왕아너스 메트로'모델하우스는 초역세권 입지와 변화하는 라이프스타일에 맞춘 혁신평면으로 오픈 당일부터 관람객의 줄이 이어지면서 관람객의 호평을 받았다.|
|1|koBART|아파트 분양시장이 실수요자 중심으로 바뀌면서 초역세권 입지와 변화하는 라이프스타일에 맞춘 혁신평면이 아파트 선택에 미치는 영향력이 커지고 있는 가운데, 태왕이 지난 22일 공개한 ‘성당 태왕아너스 메트로’ 모델하우스를 찾은 방문객들은 합리적인 분양가와 중도금무이자 등의 분양조건도 실수요자에게 유리해 높은 청약경쟁률을 기대했다.|



## Model Performance
- Test Data 기준으로 rouge score를 산출함
- Score 산출 방법은 Dacon 한국어 문서 생성요약 AI 경진대회 metric을 활용함
- Debating day에서 크롤링한 토론대화 데이터를 요약한 요약본들에 사람이 점수를 매기는 Human Evaluation 사용

| | rouge-1 |rouge-2|rouge-l|
|-------|--------:|--------:|--------:|
| Precision| 0.515 | 0.351|0.415|
| Recall| 0.538| 0.359|0.440|
| F1| 0.505| 0.340|0.415|

| epoch| 10 |20|30|40|50|
|-------|--------:|--------:|--------:|--------:|--------:|
| Human evaluation| 5.4|5.7|5.9|6.7|6.2|

## Demo
- 학습한 model binary 추출 작업이 필요함
   - pytorch-lightning binary --> huggingface binary로 추출 작업 필요
   - hparams의 경우에는 <b>./logs/tb_logs/default/version_0/hparams.yaml</b> 파일을 활용
   - model_binary 의 경우에는 <b>./logs/kobart_summary-model_chp</b> 안에 있는 .ckpt 파일을 활용
   - 변환 코드를 실행하면 <b>./kobart_summary</b> 에 model binary 가 추출 됨
  
```
 python get_model_binary.py --hparams hparam_path --model_binary model_binary_path
```
