# Discussion-Korea Offensive Comment Classifier

### For Binary Classification Case
- Raw data for training model stored on `binary/data/raw`
- `$ pip install -r requirements.txt`
- `$ sh train.sh`

### For Multi Label Classification Case
- Processed data for training model stored on `multi/data/processed`
- `$ pip install -r requirements.txt`
- `$ sh train.sh`
- `$ sh generate.sh`

## Overall Architecture
<p align="center">
    <img width="50%" height="50%" alt="인공 지능 모델" src="https://user-images.githubusercontent.com/67726968/171651834-598a6816-397f-4665-97ea-55bea149353f.png">
</p>

- For training the summarization model, we use the pretrained ```ko-bart``` model 
- For training the offensive comment classification model, we use the pretrained ```klue-roberta``` model

## Folder Architecture
```
  ./multi
    ./src
    ├── main.py - main 
    ├── test.py - test 
    ├── model.py - contain all models
    ├── option.py - options (arguments, model configs, etc.)
    ├── train.py - train/eval/test
    ├── multi_label.py - multi label version2 model training
    ├── generate.py - generate outputs
    └── utils - utilities
        ├── dataset.py - dataset & dataloader 
        ├── preprocessing.py - dataset preprocessing & save
        └── utils.py - others (set seed, num_workers, etc.)
  ./binary
  ...
  ./crawling
    ├── main.py - main 
    ├── page_comment.py - page comment crawling
    └── page_link.py - page link crawling
 ```
