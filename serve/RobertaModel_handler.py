from abc import ABC
import json
import logging
import os
import torch
import transformers
from transformers import AutoTokenizer, AutoModel, AutoConfig
from ts.torch_handler.base_handler import BaseHandler
import torch.nn as nn
import importlib.util
import inspect

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
        """In this initialize function, the BERT model is loaded and
        the Layer Integrated Gradients Algorithm for Captum Explanations
        is initialized here.
        Args:
            ctx (context): It is a JSON Object containing information
            pertaining to the model artefacts parameters.
        """
        self.manifest = ctx.manifest
        properties = ctx.system_properties
        model_dir = properties.get("model_dir")
        serialized_file = self.manifest["model"]["serializedFile"]
        model_pt_path = os.path.join(model_dir, serialized_file)
        model_file = self.manifest["model"].get("modelFile", "")
        model_path = os.path.join(model_dir, model_file)
        self.tokenizer = AutoTokenizer.from_pretrained("klue/roberta-base")

        self.device = torch.device(
            "cuda:" + str(properties.get("gpu_id"))
            if torch.cuda.is_available() and properties.get("gpu_id") is not None
            else "cpu"
        )

        # Loading the model and tokenizer from checkpoint and config files based on the user's choice of mode
        # further setup config can be added.
        
        # self.model = AutoModel.from_pretrained("klue/roberta-base", 2)
        # self.model = RobertaModel("klue/roberta-base", 2)
        
        
        # self.model.load_state_dict(torch.load(model_pt_path, map_location=torch.device('cpu')))
        # self.model = torch.jit.load(model_pt_path, map_location=self.device) # bin file

        module = importlib.import_module(model_file.split(".")[0])
        model_class_definitions = [cls[1] for cls in inspect.getmembers(module, lambda member: inspect.isclass(member) and member.__module__ == module.__name__)]
        
        if len(model_class_definitions) != 1:
            raise ValueError(
                "Expected only one class as model definition. {}".format(
                    model_class_definitions
                )
            )
        model_class = model_class_definitions[0]
        self.model = model_class("klue/roberta-base", 2)
    
    
        self.model.load_state_dict(torch.load(model_pt_path, map_location=torch.device('cpu'))['model_state_dict'])
        
        self.model.to(self.device)
        self.model.eval()

        logger.info(
            "Transformer model from path %s loaded successfully", model_dir
        )

        # Read the mapping file, index to object name
        # 1 0 output을 json string으로 변경
        mapping_file_path = os.path.join(model_dir, "index_to_name.json")
        if os.path.isfile(mapping_file_path):
            with open(mapping_file_path) as f:
                self.mapping = json.load(f)
        else:
            logger.warning("Missing the index_to_name.json file.")
        self.initialized = True

    def preprocess(self, requests):
        """Basic text preprocessing, based on the user's chocie of application mode.
        Args:
            requests (str): The Input data in the form of text is passed on to the preprocess
            function.
        Returns:
            list : The preprocess function returns a list of Tensor for the size of the word tokens.
        """
        input_name = requests[0]["body"]["name"]
        input_text = requests[0]["body"]["text"]
        
        input = torch.tensor(self.tokenizer.encode(input_text), device=self.device)
        print(input)
        
        return (input.unsqueeze(0), input_name)

    def inference(self, input):
        """Predict the class (or classes) of the received text using the
        serialized transformers checkpoint.
        Args:
            input_batch (list): List of Text Tensors from the pre-process function is passed here
        Returns:
            list : It returns a list of the predicted value for the input text
        """
        name = input[1]
        input_text = input[0]
        output = self.model(input_text)
        try:
            logits, _ = output
        except:
            logits = output
            
        prediction = torch.argmax(logits, dim=-1)

        if int(prediction[0]) == 0:
            return [name + "님 " + "말을 이쁘게 하시네요"]
        else:
            return [name + "님 " + "말을 나쁘게 하시네요"]

    def postprocess(self, inference_output):
        """Post Process Function converts the predicted response into Torchserve readable format.
        Args:
            inference_output (list): It contains the predicted response of the input text.
        Returns:
            (list): Returns a list of the Predictions and Explanations.
        """
        
        return inference_output