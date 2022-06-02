# Model Serving

## Model Server Architecture
<p align="center"> <img width="50%" height="50%" alt="Model Server Architecture" src="https://user-images.githubusercontent.com/100838059/171661848-46da60e3-9358-4c89-9bdc-3d4e34aea5df.png">

## File Structure
 Because of the capacity problem, the model parameter file and the torch model archiver file(MAR) were not uploaded.
```
./serve
  ./badword_classification
    ├── classification2.py - badword classifier with flask
  ./classification
    ├── basemodel.pt - model parameter file
    ├── model.py - model file
    ├── requirements.txt
    ├── roberta_handler.py - handler file for klue-koBERTa-base binary classification model
  ./multi_label_classification
    ├── multi-base3.pt - model parameter file
    ├── model.py - model file
    ├── requirements.txt
    ├── multi_label_roberta_handler.py - handler file for klue-koBERTa-base multi-label classification model
  ./summarization
    ├── config.json
    ├── kobart_handler.py - handler file for koBART summarization model
    ├── pytorch_model.bin - model parameter file
    ├── requirements.txt
    ├── summary_version4_e23
        ├── config.json
        ├── pytorch_model.bin - model parameter file
    ├── summary_version4_e39
        ├── config.json
        ├── pytorch_model.bin - model parameter file
  ./model_store
    ├── klue-roberta-base-v1.0.mar
    ├── klue-roberta-base-v1.1.mar
    ├── kobart-v1.0.mar
    ├── kobart-v1.1.mar
    ├── kobart-v1.2.mar
    ├── kobart-v1.3.mar
    ├── multi-label-klue-roberta-base-v1.0.mar
```
 
 Make summarization model mar file: 
```
 zsh serve/make_summarization_mar.sh
```
 
 Make binary classification model mar file:
```
 zsh serve/make_classification_mar.sh
```
 
 Make multi-label classification model mar file:
```
 zsh serve/make_multi_label_classification_mar.sh
```
 
 Serve badword classifier on your local environment:
```
 python serve/badword_classification/classification2.py
```
 
 Serve models on your local environment:
```
 zsh serve/start_server.sh
```
 
 Serve models on the docker:
```
 docker run --gpus all -it -p 8080:8080 --name torchserve -v C:\Users\admin\model-store:/home/model-server/model-store pytorch/torchserve:latest torchserve --start --model-store model-store --models classification1=klue-roberta-base-v1.1.mar classification3=multi-label-klue-roberta-base-v1.0.mar summarization=kobart-v1.3.mar --ncs
```

## Use model
```
 python serve/request_example.py
```
<p align="center"> <img width="50%" height="50%"  alt="request_example.py" src="https://user-images.githubusercontent.com/100838059/171678696-fbc64e5d-98e7-4c8d-acd5-4932e34cd7c4.png">

## OpenSource License

- [TorchServe (Apache 2.0)](https://github.com/pytorch/serve/blob/master/LICENSE)
- [Gentleman (EULA)](https://github.com/organization/Gentleman/blob/master/LICENSE.md)
