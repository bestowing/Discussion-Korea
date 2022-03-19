import os
import os.path as p
import torch
from train import train
from option import get_arg_parser, set_seed
from utils.preprocessing import make_dataframe, get_dataframe
from utils.dataset import MakeDataSet, get_data_loader

from torch.utils.data import DataLoader

import gluonnlp as nlp
from kobert.utils import get_tokenizer
from kobert.pytorch_kobert import get_pytorch_kobert_model


def main():
    parser = get_arg_parser()
    args = parser.parse_args()

    # Set device
    device = torch.device("cuda:0" if torch.cuda.is_available() else "cpu")
    print(f"-- Running on {device}. --")

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

    # Loading dataloader
    print("Load dataloaders...")
    if args.model == "kobert":
        bertmodel, vocab = get_pytorch_kobert_model()
        tokenizer = nlp.data.BERTSPTokenizer(get_tokenizer(), vocab, lower=False)
        print("Make dataset")

        train_dataset = MakeDataSet(
            train_df, tokenizer=tokenizer, max_length=args.max_length
        )
        valid_dataset = MakeDataSet(
            valid_df, tokenizer=tokenizer, max_length=args.max_length
        )
        test_dataset = MakeDataSet(
            test_df, tokenizer=tokenizer, max_length=args.max_length
        )

        train_loader = DataLoader(
            train_dataset, batch_size=args.batch_size, shuffle=True
        )
        valid_loader = DataLoader(
            valid_dataset, batch_size=args.batch_size, shuffle=False
        )
        test_loader = DataLoader(
            test_dataset, batch_size=args.batch_size, shuffle=False
        )
    else:
        raise ("Not Implemented")

    print("Train model...\n")

    train(
        args.model,
        bertmodel,
        train_loader,
        valid_loader,
        num_classes=args.num_classes,
        lr=args.lr,
        max_epochs=args.max_epochs,
        weight_decay=args.weight_decay,
        warm_up_ratio=args.warm_up_ratio,
        device=args.device,
    )


if __name__ == "__main__":
    main()
