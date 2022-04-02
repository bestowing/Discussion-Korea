from abc import ABC
import json
import logging
import os
import ast
import torch
import transformers
from transformers import AutoTokenizer
from base_handler import BaseHandler
from .model import RobertaModel

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

        self.device = torch.device(
            "cuda:" + str(properties.get("gpu_id"))
            if torch.cuda.is_available() and properties.get("gpu_id") is not None
            else "cpu"
        )
        
        self.ckpt = "./basemodel.pt"
        self.tokenizer = AutoTokenizer.from_pretrained("klue/roberta-base")
        self.device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
        self.model = RobertaModel("klue/roberta-base", 2)
        
        self.model.load_state_dict(torch.load(self.ckpt, map_location=torch.device('cpu'))['model_state_dict'])
        # self.model.to(self.device)
        
        self.model.eval()

        logger.info(
            "klue-roberta-base model from path %s loaded successfully", model_dir
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
        input = torch.tensor(self.tokenizer.encode(requests), device=self.device)
        return input.unsqueeze(0)

    def inference(self, input_text):
        """Predict the class (or classes) of the received text using the
        serialized transformers checkpoint.
        Args:
            input_batch (list): List of Text Tensors from the pre-process function is passed here
        Returns:
            list : It returns a list of the predicted value for the input text
        """
        predictions = self.model(input_text)
        prediction = torch.argmax(predictions, dim=-1)

        if int(prediction[0]) == 0:
            return 0
        else:
            return 1

    def postprocess(self, inference_output):
        """Post Process Function converts the predicted response into Torchserve readable format.
        Args:
            inference_output (list): It contains the predicted response of the input text.
        Returns:
            (list): Returns a list of the Predictions and Explanations.
        """
        return inference_output