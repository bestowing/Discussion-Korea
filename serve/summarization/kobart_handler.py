from abc import ABC
import logging
import os
import torch
import transformers
from transformers import PreTrainedTokenizerFast
from transformers.models.bart import BartForConditionalGeneration
from ts.torch_handler.base_handler import BaseHandler

logger = logging.getLogger(__name__)
logger.info("Transformers version %s",transformers.__version__)

class TransformersSeqSummaryHandler(BaseHandler, ABC):
    """
    Transformers handler class for sequence classification.
    """

    def __init__(self):
        super(TransformersSeqSummaryHandler, self).__init__()
        self.initialized = False

    def initialize(self, ctx):
        """In this initialize function, the KoBART model is loaded.
        Args:
            ctx (context): It is a JSON Object containing information
            pertaining to the model artefacts parameters.
        """
        
        # Load model path and tokenizer.
        self.manifest = ctx.manifest
        properties = ctx.system_properties
        model_dir = properties.get("model_dir")
        self.tokenizer = PreTrainedTokenizerFast.from_pretrained('digit82/kobart-summarization')
        self.device = torch.device(
            "cuda:" + str(properties.get("gpu_id"))
            if torch.cuda.is_available() and properties.get("gpu_id") is not None
            else "cpu"
        )
        
        # Load KoBART model from pytorch_model.bin.
        self.model = BartForConditionalGeneration.from_pretrained(model_dir)
        
        self.model.to(self.device)
        self.model.eval()

        logger.info(
            "KoBART model from path %s loaded successfully", model_dir
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
        
        raw_input_ids = self.tokenizer.encode(text)
        input_ids = [self.tokenizer.bos_token_id] + \
            raw_input_ids + [self.tokenizer.eos_token_id]
        
        input = torch.tensor([input_ids], device=self.device)
        return input

    def inference(self, input):
        """Predict the class (or classes) of the received text using the
        serialized transformers checkpoint.
        Args:
            input_batch (list): List of Text Tensors from the pre-process function is passed here
        Returns:
            list : It returns a list of the predicted value for the input text
        """
        text = input
        
        summary_ids = self.model.generate(text, num_beams=50, no_repeat_ngram_size = 2, max_length=1000, eos_token_id=1)
        
        result = [self.tokenizer.decode(summary_ids.squeeze().tolist(), skip_special_tokens=True)]
        
        return result

    def postprocess(self, inference_output):
        """Post Process Function converts the predicted response into Torchserve readable format.
        Args:
            inference_output (list): It contains the predicted response of the input text.
        Returns:
            (list): Returns a list of the Predictions and Explanations.
        """
        
        return inference_output