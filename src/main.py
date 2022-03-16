import os
import os.path as p 
import torch
import wandb
from datetime import datetime
from .option import (
    get_arg_parser,
    set_seed
)
from .utils.preprocessing import (
    make_dataframe,
    get_dataframe
)

def main():
    parser = get_arg_parser()
    args = parser.parse_args()
    print(args)
    
    # Set device
    #device = torch.device("cuda:0" if torch.cuda.is_avaliable() else "cpu")
    #print(f"-- Running on {device}. --")
    
    # Set seed
    set_seed(args.seed)
    
    # Data preprocessing
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
    
if __name__ == "__main__":
    main()
    
