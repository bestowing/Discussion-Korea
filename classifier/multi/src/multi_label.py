import os
import os.path as p 
import torch
import wandb
import numpy as np
from transformers import AutoTokenizer
from .utils.tokenization import KoBertTokenizer
from .model import RobertaModel, StudentModel, MultiLabelClassifier
from .train import train, train_distill, test
from datetime import datetime
from .option import (
    get_arg_parser,
    set_seed
)
from .utils.preprocessing import (
    load_multi_tsv_data
)
from .utils.dataset import (
    MakeMultiDataset,
    MakeMultiDataset_diff,
    load_data_loader
)

def main():
    parser = get_arg_parser()
    args = parser.parse_args()
    
    # Set device
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    print(f"-- Running on {device}. --")
    
    # Set seed 
    set_seed(args.seed)
    
    # Data preprocessing
    # In Multi-label case There is already processed dataset
    tokenizer = AutoTokenizer.from_pretrained(args.model_path)
    
    # Loading dataset
    print("Load datasets...")
    train_path = p.join(args.data_path, "processed/multilabel_train.tsv")
    test_path = p.join(args.data_path, "processed/multilabel_valid.tsv")
    
    train_sentence, train_label = load_multi_tsv_data(train_path)
    test_sentence, test_label = load_multi_tsv_data(test_path)
    
    #train_dataset = MakeMultiDataset(train_sentence, train_label, args, tokenizer)
    #test_dataset = MakeMultiDataset(test_sentence, test_label, args, tokenizer)
    
    train_label = np.array(train_label)
    test_label = np.array(test_label)
    
    train_kind_label = train_label[:,(0,1,2,3,4,5,6,7,8,10)].tolist()
    train_toxic_label = train_label[:,-2].tolist()
    
    test_kind_label = test_label[:,(0,1,2,3,4,5,6,7,8,10)].tolist()
    test_toxic_label = test_label[:,-2].tolist()
    
    #print(len(train_kind_label))
    #print(len(train_toxic_label))
    train_dataset = MakeMultiDataset(train_sentence, train_label, args, tokenizer)
    test_dataset = MakeMultiDataset(test_sentence, test_label, args, tokenizer)    
    
    # Loading dataloader
    print("Load dataloaders...")
    train_loader = load_data_loader(train_dataset, batch_size=32, shuffle=True)
    test_loader = load_data_loader(test_dataset, batch_size=32, shuffle=False)
    
    # Loading Model
    print("Get model...")
    model = MultiLabelClassifier(args.model_path)
        
    # wandb
    if args.debug:
        print("DEBUGGING MODE - Start without wandb")
        wandb.init(mode="disabled")
    else: 
        wandb.init(
            project = "offensive-classifier", entity="capstone-team-a"
            )
        wandb.config.update(args)
        wandb.run.name = datetime.now().strftime('%Y-%m-%d %H:%M klue-roberta')
        
        # Start train
        print("Start train.")
        ckpt_ = train(
            model = model,
            tokenizer=tokenizer,
            train_loader = train_loader,
            valid_loader = None,
            num_epochs = args.n_epochs,
            device=device,
            lr = args.learning_rate,
            logging_step = 100
        )
        print("Finish.\n")
        
        """
        # Start test
        print("Start test")
        model.load_state_dict(torch.load(ckpt_)['model_state_dict'])
        test(
            model = model,
            test_loader = test_loader,
            device = device
        )
        print("All Finish.\n")
        """
    
    
if __name__ == "__main__":
    main()
    
