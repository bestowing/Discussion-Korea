#!/bin/sh
#SBATCH -J summarize
#SBATCH -o kobart.out
#SBATCH -e kobart.err
#SBATCH --time 100:00:00

export TORCH_CUDA_ARCH_LIST=7.5

CUDA_VISIBLE_DEVICES=4,5,6,7 python3 train.py  --gradient_clip_val 1.0  \
                 --train_file data/dacon_aihub_total.tsv \
                 --test_file data/dacon_aihub_total.tsv \
                 --max_epochs 20 \
                 --default_root_dir logs \
                 --gpus 4 \
                 --strategy ddp \
                 --batch_size 8 \
                 --num_workers 4

# CUDA_VISIBLE_DEVICES=1,2 python3 train.py --gradient_clip_val 1.0 \
#                 --max_epochs 50 \
#                 --default_root_dir logs \
#                 --gpus 2 \
#                 --strategy ddp \
#                 --batch_size 4 \
#                 --num_workers 4



