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
    parser.add_argument('--data-path', '-r', type=str, default="data/",
                        help='Data path')

    parser.add_argument('--model_path', type=str, default="monologg/distilkobert",
                        help='pretrained model')
    parser.add_argument('--n_epochs', type=int, default=10,
                        help='number of epochs')
    parser.add_argument('--lr', type=float, default=1e-4,
                        help='learning rate')
    
    parser.add_argument('--world_size', default=1, type=int,
                    help='number of nodes for distributed training')

    parser.add_argument('--rank', default=1, type=int,
                    help='node rank for distributed training')

    parser.add_argument('--model', default='distilkobert', type=str,
                    help='node rank for distributed training')

    return parser

if __name__ == '__main__':
    parser = get_arg_parser()
    args = parser.parse_args()