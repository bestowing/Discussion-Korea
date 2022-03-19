import os
import os.path as p
from tqdm import tqdm

import torch
import torch.nn as nn
from torch.optim import AdamW

from transformers.optimization import (
    get_cosine_schedule_with_warmup,
    get_linear_schedule_with_warmup,
)

from model import KoBertClassficationModel

import wandb
import time


def calc_accuracy(x, y):
    pred = torch.argmax(x, dim=1)
    train_acc = (pred == y).float().mean().item()
    return train_acc


def save_ckpt(ckpt_path, model, epoch, train_loss, best_loss):
    torch.save(
        {
            "epoch": epoch,
            "model_state_dict": model.state_dict(),
            "train_loss": train_loss,
            "best_loss": best_loss,
        },
        ckpt_path,
    )


def validate(model, data_loader, device):
    total_loss = 0
    accuracy = 0
    loss_fn = nn.CrossEntropyLoss()
    model.eval()
    with torch.no_grad():
        for step, batch in enumerate(tqdm(data_loader)):
            out = model(batch)
            labels = batch["label"].to(device)
            loss = loss_fn(out.view(-1, 2), labels.view(-1))
            total_loss += loss
            accuracy += calc_accuracy(out, labels)

    total_loss = loss / len(data_loader)
    accuracy /= len(data_loader)
    return total_loss, accuracy


def train(
    model,
    bertmodel,
    train_loader,
    valid_loader,
    ckpt_path="model_save",
    num_classes=2,
    lr=1e-5,
    max_epochs=4,
    weight_decay=0.01,
    warm_up_ratio=0.1,
    device="cuda",
):
    if model == "kobert":
        model = KoBertClassficationModel(
            lm_model=bertmodel, num_classes=num_classes, device=device
        )
    else:
        raise NotImplementedError("Not Implemented model")

    os.makedirs(ckpt_path, exist_ok=True)

    no_decay = ["bias", "LayerNorm.weight"]
    optimizer_grouped_parameters = [
        {
            "params": [
                p
                for n, p in model.named_parameters()
                if not any(nd in n for nd in no_decay)
            ],
            "weight_decay": weight_decay,
        },
        {
            "params": [
                p
                for n, p in model.named_parameters()
                if any(nd in n for nd in no_decay)
            ],
            "weight_decay": 0.0,
        },
    ]
    t_total = len(train_loader) * max_epochs
    warm_up_ratio = 0.1
    warmup_step = int(t_total * warm_up_ratio)

    loss_fn = nn.CrossEntropyLoss()

    optimizer = AdamW(optimizer_grouped_parameters, lr=lr)
    scheduler = get_linear_schedule_with_warmup(
        optimizer, num_warmup_steps=warmup_step, num_training_steps=t_total
    )

    model = model.to(device)
    t0 = time.time()
    best_loss = float("inf")
    train_loss = []

    # wandb.init()

    for epoch in tqdm(range(max_epochs)):
        epoch_accuracy = 0
        epoch_loss = 0
        model.train()
        for step, batch in enumerate(tqdm(train_loader)):
            optimizer.zero_grad()
            out = model(batch)
            labels = batch["label"].to(device)
            loss = loss_fn(out.view(-1, 2), labels.view(-1))
            epoch_loss += loss
            loss.backward()
            nn.utils.clip_grad_norm_(model.parameters(), 1)
            optimizer.step()
            scheduler.step()
            epoch_accuracy += calc_accuracy(out, labels)

            # wandb.log({"train_loss": epoch_loss / (step + 1)})

        epoch_loss /= len(train_loader)
        epoch_accuracy /= len(train_loader)

        train_loss.append(epoch_loss)

        valid_loss, valid_acc = validate(model, valid_loader, device)

        if valid_loss < best_loss:
            best_loss = valid_loss
            save_ckpt(
                ckpt_path=p.join(ckpt_path, f"checkpoint_epoch_{epoch +1}.pt"),
                model=model,
                epoch=epoch + 1,
                train_loss=train_loss,
                best_loss=valid_loss,
            )
        # Wandb logging
        # wandb.log({"valid_loss": valid_loss})

        elapsed_time = (time.time() - t0) / 60

        print(
            f"epoch {epoch+1} train_loss: {epoch_loss:.4f} train accuracy: {epoch_accuracy:.4f} time: {elapsed_time:.4f} minutes"
        )
        print(
            f"epoch {epoch+1} valid_loss: {valid_loss:.4f} validation_accuracy: {valid_acc:.4f}"
        )
        print()
