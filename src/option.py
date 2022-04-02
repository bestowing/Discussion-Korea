import random
import argparse
import os

import numpy as np
import torch

def set_seed(seed):
    os.environ['PYTHONHASHSEED'] = str(seed)
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)
    
def get_arg_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument('--seed', '-s', type=int, default=42,
                        help='Random seed')
    parser.add_argument('--data-path', type=str, default="data/",
                        help='Data path')
    parser.add_argument('--update', type=str, default="ckpt/update.pt")
    parser.add_argument('--mode', type=str, default="base",
                        help='Distillation mode')
    parser.add_argument('--model-path',type=str, default="klue/roberta-base")
    parser.add_argument('--learning-rate', type=float, default=1e-5)
    parser.add_argument('--n-epochs', type=int, default=3)
    parser.add_argument('--DEBUG', dest='debug', action='store_true',
                        help="Disable the wandb to log if debug option is true")
    return parser

if __name__ == '__main__':
    parser = get_arg_parser()
    args = parser.parse_args()