# Torchserve Serving Model

* make klue-roberta-base.mar
  * torch-model-archiver --model-name klue-roberta-base --model-file model.py --serialized-file basemodel.pt --version 1.0 --handler RobertaModel_handler.py

* start torchserve
  * torchserve --start --model-store ./ --models my_tc=klue-roberta-base.mar --ncs

* use curl to request
  * curl --header "Content-Type: application/json" --request POST --data '{"name":"김석", "text":"공부하기 너무 시러요"}' http://localhost:8080/predictions/my_tc
