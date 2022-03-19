#!/bin/sh
#SBATCH -J train
#SBATCH -o train.out
#SBATCH -e train.err
#SBATCH --time 48:00:00
#SBATCH --gres=gpu:1

python main.py --lr 1.5e-5 --max-epochs 4 --batch-size 16
