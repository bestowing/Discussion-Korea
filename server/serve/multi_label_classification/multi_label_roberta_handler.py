from abc import ABC
import logging
import os
import torch
import transformers
from transformers import AutoTokenizer
from ts.torch_handler.base_handler import BaseHandler
import importlib.util
import inspect
import json

logger = logging.getLogger(__name__)
logger.info("Transformers version %s",transformers.__version__)

class TransformersSeqClassifierHandler(BaseHandler, ABC):
    """
    Transformers handler class for sequence classification.
    """
    
    def __init__(self):
        super(TransformersSeqClassifierHandler, self).__init__()
        self.initialized = False

    def initialize(self, ctx):
        """In this initialize function, the KLUE RoBERTa base model is loaded.
        Args:
            ctx (context): It is a JSON Object containing information
            pertaining to the model artefacts parameters.
        """
        
        # Load model path and tokenizer.
        self.manifest = ctx.manifest
        properties = ctx.system_properties
        model_dir = properties.get("model_dir")
        serialized_file = self.manifest["model"]["serializedFile"]
        model_pt_path = os.path.join(model_dir, serialized_file)
        model_file = self.manifest["model"].get("modelFile", "")
        self.tokenizer = AutoTokenizer.from_pretrained("klue/roberta-base")
        self.device = torch.device(
            "cuda:" + str(properties.get("gpu_id"))
            if torch.cuda.is_available() and properties.get("gpu_id") is not None
            else "cpu"
        )
        
        # Load RobertaModel from model.py.
        module = importlib.import_module(model_file.split(".")[0])
        model_class_definitions = [cls[1] for cls in inspect.getmembers(module, lambda member: inspect.isclass(member) and member.__module__ == module.__name__)]
        
        if len(model_class_definitions) != 1:
            raise ValueError(
                "Expected only one class as model definition. {}".format(
                    model_class_definitions
                )
            )
        model_class = model_class_definitions[0]
        self.model = model_class("klue/roberta-base", 11)
    
        # Load state_dict from basemodel.pt
        self.model.load_state_dict(torch.load(model_pt_path, map_location=torch.device(self.device))['model_state_dict'])
        
        self.model.to(self.device)
        self.model.eval()

        logger.info(
            "Multi-label KLUE RoBERTa base model from path %s loaded successfully", model_dir
        )

    def preprocess(self, requests):
        """Basic text preprocessing, based on the user's chocie of application mode.
        Args:
            requests (str): The Input data in the form of text is passed on to the preprocess
            function.
        Returns:
            list : The preprocess function returns a list of Tensor for the size of the word tokens.
        """
        
        text = requests[0]["body"]["text"]
        logger.info(f"text: {text}")
        
        input = torch.tensor(self.tokenizer.encode(text), device=self.device)
        
        return input.unsqueeze(0)

    def inference(self, input):
        """Predict the class (or classes) of the received text using the
        serialized transformers checkpoint.
        Args:
            input_batch (list): List of Text Tensors from the pre-process function is passed here
        Returns:
            list : It returns a list of the predicted value for the input text
        """
        
        text = input
        output = self.model(text)
        try:
            logits, _ = output
        except:
            logits = output
            
        return logits.squeeze().detach()

    def postprocess(self, inference_output):
        """Post Process Function converts the predicted response into Torchserve readable format.
        Args:
            inference_output (list): It contains the predicted response of the input text.
        Returns:
            (list): Returns a list of the Predictions and Explanations.
        """
        
        target = ["여성/가족", "남성", "성소수자", "인종/국적", "연령", "지역", "종교", "혐오", "욕설", "clean", "개인지칭"]
        
        
        prediction = int(torch.argmax(inference_output))
        
        return [target[prediction]]
        
        # inference_output_dict = {"not_toxic_logit": float(inference_output[0]),"toxic_logit": float(inference_output[1]), "prediction": int(prediction)}
        
        # inference_output = json.dumps(inference_output_dict)
        
        # return [inference_output]