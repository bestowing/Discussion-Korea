import os
import os.path as p 
import torch
import wandb
from transformers import AutoTokenizer
from .model import RobertaModel
from .train import train
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

    tokenizer = AutoTokenizer.from_pretrained(args.model_path)
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
    
    # Loading Model
    print("Get model...")
    model = RobertaModel(args.model_path, 2)
    
    # wandb
    wandb.init(
        project = "offensive-classifier", entity="capstone-team-a"
    )
    wandb.config.update(args)
    wandb.run.name = datetime.now().strftime('%Y-%m-%d %H:%M klue-roberta')
    
    # Strat train
    print("Start train.")
    train(
        model = model,
        tokenizer=tokenizer,
        train_loader = train_loader,
        valid_loader = valid_loader,
        num_epochs = args.n_epochs,
        device=device,
        lr = args.learning_rate,
        logging_step = 100
    )
    print("Finish.\n")
    
    
if __name__ == "__main__":
    main()
    
