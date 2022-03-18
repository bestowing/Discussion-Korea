import os
import os.path as p

import wandb
import numpy as np
import torch
import torch.nn as nn
import re 

def save_ckpt(ckpt_path, model, epoch, train_loss, best_loss):
    torch.save({
        "epoch": epoch,
        "model_state_dict" : model.state_dict(),
        "train_loss" : train_loss,
        "best_loss" : best_loss
    }, ckpt_path)
    
def validate(model, valid_loader, device, tokenizer):
    model.eval()
    
    with torch.no_grad():
        epoch_loss = 0.0
        for step, batch in enumerate(valid_loader):
            input_ids, label = batch
            input_ids, label = input_ids.to(device), label.to(device)
            output = model(input_ids, labels=label)
            logits, loss = output
            prediction = torch.argmax(logits, dim=-1)
            epoch_loss += loss.item()
            if step % 10 == 0:
                sent = tokenizer.decode(input_ids[0])
                sent = re.sub('[^.-?-가-힣ㄱ-ㅎㅏ-ㅣ]',' ',sent).strip()
                if int(prediction[0]) == 1:
                    predict = "toxic"
                else:
                    predict = "not toxic"
                print(sent + ' : ' + predict)
        valid_loss = epoch_loss/len(valid_loader)
            
    return valid_loss
    
def train(
    model,  
    train_loader, 
    valid_loader,
    optimizer='adam',
    lr=1e-5,
    ckpt_path='./ckpt',
    num_epochs=3,
    logging_step=100,
    device=None,
    tokenizer=None
    ):
    # make check point path
    os.makedirs(ckpt_path, exist_ok=True)
    
    #optimizer
    #optimizer = None
    
    if optimizer == 'adam':
        optimizer = torch.optim.Adam(model.parameters(), lr=lr)
    else:
        raise NotImplementedError
     
    losses = []
    train_loss = []
    best_loss = float('inf')
    model.to(device)   
    for epoch in range(num_epochs):
        model.train()
        epoch_loss = 0.0
        for step, batch in enumerate(train_loader):
            input_ids, label = batch
            input_ids, label = input_ids.to(device), label.to(device)
            output = model(input_ids, labels=label)
            logits, loss = output
            loss.backward()
            
            optimizer.step()
            optimizer.zero_grad()
            
            epoch_loss += loss.item()
            wandb.log(
                {
                    'train_loss':epoch_loss/(step+1)
                }
            )
            if (step+1) % logging_step == 0:
                print(f"[Epoch {epoch + 1}/{num_epochs}] Step {step  + 1}/{len(train_loader)} | loss: {epoch_loss/(step + 1): .3f}")
        
        train_loss.append(epoch_loss/len(train_loader))
        valid_loss = validate(model, valid_loader, device, tokenizer)
        
        if valid_loss < best_loss:
            best_loss = valid_loss
            save_ckpt(
                ckpt_path = p.join(ckpt_path, f"checkpoint_epoch_{epoch +1}.pt"),
                model = model, epoch = epoch +1,
                train_loss = train_loss, best_loss = valid_loss
            )
        # Wandb logging
        wandb.log({
            "valid_loss": valid_loss
        })
    