# torchserve --start --model-store model_store --models classification=klue-roberta-base-v1.0.mar summarization=kobart-v1.0.mar --ncs

torchserve --start --model-store model_store --models classification1=multi-label-klue-roberta-base-v1.0.mar classification2=klue-roberta-base-v1.1.mar --ncs