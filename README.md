# Model Serving

## Model Server Architecture
<p align="center"> <img width="50%" height="50%" alt="Model Server Architecture" src="https://user-images.githubusercontent.com/100838059/171661848-46da60e3-9358-4c89-9bdc-3d4e34aea5df.png">

## File Structure
 Because of the capacity problem, the model parameter file and the torch model archiver file(MAR) were not uploaded.
```
./serve
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
 
 Make summarization model mar file: zsh make_summarization_mar.sh
 
 Make binary classification model mar file: zsh make_classification_mar.sh
 
 Make multi-label classification model mar file: zsh make_multi_label_classification_mar.sh
 
 Run the server on your local environment: zsh start_server.sh
 
 Run the server at the same time as the docker environment runs: see docker_run.txt

## OpenSource License

- [TorchServe (Apache 2.0)](https://github.com/pytorch/serve/blob/master/LICENSE)
