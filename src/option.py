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
    return parser

if __name__ == '__main__':
    parser = get_arg_parser()
    args = parser.parse_args()