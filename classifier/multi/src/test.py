import os
import os.path as p 
import torch
import wandb
from transformers import AutoTokenizer
from .utils.tokenization import KoBertTokenizer
from .model import RobertaModel, StudentModel
from .train import train, train_distill, test
from datetime import datetime
from .option import (
    get_arg_parser,
    set_seed
)
from .utils.preprocessing import (
    make_dataframe,
    get_dataframe
)
from .utils.dataset import (
    MakeDataset,
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
    
    if args.mode != 'distill':
        tokenizer = AutoTokenizer.from_pretrained(args.model_path)
    
    else:
        tokenizer = KoBertTokenizer.from_pretrained('monologg/kobert')
  
    data_root = p.join(args.data_path, "processed/")
    os.makedirs(data_root, exist_ok=True)
    if not (
        p.exists(p.join(data_root, "train.csv"))
        and p.exists(p.join(data_root, "valid.csv"))
        and p.exists(p.join(data_root, "test.csv"))
    ):
        print("Preprocessing...")
        make_dataframe(src_path=args.data_path, dst_path=data_root)
        print("Finish.\n")
    else:
        print("Processed set already exists.")

    # Loading dataframe
    print("Make dataframe...")
    train_df, valid_df, test_df = get_dataframe(data_root)
    print("Finish.\n")
    
    # Loading dataset
    print("Load datasets...")
    train_dataset = MakeDataset(train_df, args, tokenizer)
    valid_dataset = MakeDataset(valid_df, args, tokenizer)
    test_dataset = MakeDataset(test_df, args, tokenizer)
    
    # Loading dataloader
    print("Load dataloaders...")
    train_loader = load_data_loader(train_dataset, batch_size=32, shuffle=True)
    valid_loader = load_data_loader(valid_dataset, batch_size=32, shuffle=False)
    test_loader = load_data_loader(test_dataset, batch_size=32, shuffle=False)
    
    if args.mode != 'distill':
        # Loading Model
        print("Get model...")
        model = RobertaModel(args.model_path, 2)
        
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
        
        # Start test
        print("Start test")
        model.load_state_dict(torch.load("/home/chaeyoon-jang/mass_for_qg/etc/ckpt/basemodel.pt")['model_state_dict'])
        test(
            model = model,
            test_loader = test_loader,
            device = device
        )
        print("All Finish.\n")
    
    else:
        # Loading Model
        print("Get model...")
        t_model = RobertaModel(args.model_path, 2)
        t_model.load_state_dict(torch.load("/home/chaeyoon-jang/mass_for_qg/etc/ckpt/basemodel.pt")['model_state_dict'])
        
        model = StudentModel(2)
        # wandb
        if args.debug:
            print("DEBUGGING MODE - Start without wandb")
            wandb.init(mode="disabled")
        else: 
            wandb.init(
                project = "offensive-classifier", entity="capstone-team-a"
            )
            wandb.config.update(args)
            wandb.run.name = datetime.now().strftime('%Y-%m-%d %H:%M distill-roberta')
        
        # Start test
        print("Start test")
        model.load_state_dict(torch.load("/home/chaeyoon-jang/mass_for_qg/etc/ckpt/distill_checkpoint.pt")['model_state_dict'])
        test(
            model = model,
            test_loader = test_loader,
            device = device,
            distill=True
        )
        print("All Finish.\n")
    
if __name__ == "__main__":
    main()