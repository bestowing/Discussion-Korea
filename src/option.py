import random
import argparse
import os

import numpy as np
import torch


def set_seed(seed):
    os.environ["PYTHONHASHSEED"] = str(seed)
    random.seed(seed)
    np.random.seed(seed)
    torch.manual_seed(seed)
    torch.cuda.manual_seed(seed)


def get_arg_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument("--seed", "-s", type=int, default=42, help="Random seed")
    parser.add_argument("--data-path", type=str, default="../data/", help="Data path")
    parser.add_argument("--model", type=str, default="kobert")
    parser.add_argument("--num-classes", type=int, default=2)
    parser.add_argument("--num-workers", type=int, default=4)
    parser.add_argument("--batch-size", type=int, default=8)
    parser.add_argument("--lr", type=float, default=1e-5)
    parser.add_argument("--weight-decay", type=float, default=1e-2)
    parser.add_argument("--warm-up-ratio", type=float, default=1e-1)
    parser.add_argument("--device", type=str, default="cuda")
    parser.add_argument("--max-length", type=int, default=500)
    parser.add_argument("--max-epochs", type=int, default=3)
    return parser


if __name__ == "__main__":
    parser = get_arg_parser()
    args = parser.parse_args()
