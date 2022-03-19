#!/bin/sh
#SBATCH -J train
#SBATCH -o train.out
#SBATCH -e train.err
#SBATCH --time 48:00:00
#SBATCH --gres=gpu:1

python main.py --lr 2e-5 --max-epochs 5 --batch-size 24 --weight-decay 0.3
