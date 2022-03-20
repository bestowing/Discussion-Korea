import os
import os.path as p 
import torch
import wandb
from transformers import AutoTokenizer
from tokenization_kobert import KoBertTokenizer
from model import DistilBert, KoBert, RobertaModel
from train import train
from datetime import datetime
from option import (
    get_arg_parser,
    set_seed
)
from utils.preprocessing import (make_dataframe, get_dataframe)
from utils.dataset import (MakeDataset,load_data_loader)

import torch.multiprocessing as mp
import torch.distributed as dist
from torch.nn.parallel import DistributedDataParallel as DDP
from torch.utils.data.distributed import DistributedSampler

def setup(rank, world_size):
    # initialize the process group
    dist.init_process_group("nccl", rank=rank, world_size=world_size)


def main():
    parser = get_arg_parser()
    args = parser.parse_args()
  
    world_size = args.world_size
    mp.spawn(main_worker, args = (world_size, ), nprocs = world_size, join = True)
   

def main_worker(rank, world_size):
    parser = get_arg_parser()
    args = parser.parse_args()
    
    # Set devices
    print("Use GPU: {} for training".format(rank))
    setup(rank, world_size)    
    
    
    # Set seed 
    set_seed(args.seed)
    
    # Data preprocessing
    if args.model=='distilkobert':
        tokenizer = KoBertTokenizer.from_pretrained(args.model_path)   
    elif args.model=='roberta':
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
    
    # initialize the DistributedSampler
    print("distribute datasets...")
    train_sampler = DistributedSampler(train_dataset)
    test_sampler = DistributedSampler(test_dataset)
    valid_sampler = DistributedSampler(valid_dataset)

    

    # Loading dataloader
    print("Load dataloaders...")
    train_loader = load_data_loader(train_dataset, train_sampler, batch_size=24)
    test_loader = load_data_loader(test_dataset, test_sampler,batch_size=24)
    valid_loader = load_data_loader(valid_dataset, valid_sampler,batch_size=24)



    # Loading Model
    print("Get model...")
    print("rank:",rank)
    if args.model=='roberta':
        model = RobertaModel(args.model_path, 2).to(rank)   
    elif args.model=='distilkobert':
        model = DistilBert(args.model_path, 2).to(rank)

    
    model = DDP(
        model,
        device_ids=[rank],
        find_unused_parameters = True
    )
    
    # wandb
    if rank==0:
        wandb.init(
            project = "offensive-classifier", entity="capstone-team-a",group="DDP"
        )
        wandb.config.update(args)
        wandb.run.name = datetime.now().strftime('%Y-%m-%d %H:%M distil-bert')

    
    
    # Strat train
    print("Start train.")
    train(
        model = model,
        tokenizer=tokenizer,
        train_loader = train_loader,
        valid_loader = valid_loader,
        num_epochs = args.n_epochs,
        device=rank,
        lr = args.lr,
        logging_step = 100,
        rank=rank
    )
    print("Finish.\n")
    
    
if __name__ == "__main__":
    os.environ['MASTER_ADDR'] = '127.0.0.1'
    os.environ['MASTER_PORT'] = '6006'
    os.environ['CUDA_LAUNCH_BLOCKING'] = "1"
    os.environ["CUDA_VISIBLE_DEVICES"] = "1,2,3,4"
    os.environ["TOKENIZERS_PARALLELISM"] = "true"
    main()