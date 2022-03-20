#!/bin/sh
#SBATCH -J distilBert
#SBATCH -o distilBert.out
#SBATCH -e distilBert.err
#SBATCH --time 24:00:00

python3 src/main.py --model_path 'monologg/distilkobert' --world_size 4 --n_epochs 5 --model 'distilkobert'
python3 src/main.py --model_path 'klue/roberta-base' --world_size 4 --n_epochs 5 --model 'roberta'