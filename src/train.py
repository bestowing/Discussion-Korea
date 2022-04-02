import os
import os.path as p
import re 

import wandb
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from sklearn.metrics import f1_score, accuracy_score

def save_ckpt(ckpt_path, model, epoch, train_loss, best_loss):
    torch.save({
        "epoch": epoch,
        "model_state_dict" : model.state_dict(),
        "train_loss" : train_loss,
        "best_loss" : best_loss
    }, ckpt_path)
    return ckpt_path

def distillation_loss(logits, labels, teacher_logits, num_labels=2, alpha=0.1, T=10):
    """
    Calculate Distillation Loss for Student Model
    """
    ce_loss = nn.CrossEntropyLoss()
    student_loss = ce_loss(logits.view(-1,self.num_labels), labels.view(-1))
    distillation_loss = nn.KLDivLoss(reduction='batchmean')(F.log_softmax(logits/T, dim=1), F.softmax(teacher_logits/T, dim=1)) * (T * T)
    total_loss = alpha * student_loss + (1-alpha) * distillation_loss
    
    return total_loss
    
def validate(model, valid_loader, device, tokenizer, distill=False):
    model.eval()
    ce_loss = nn.CrossEntropyLoss()
    with torch.no_grad():
        epoch_loss = 0.0
        for step, batch in enumerate(valid_loader):
            input_ids, label = batch
            input_ids, label = input_ids.to(device), label.to(device)
            
            if distill:
                logits = model(input_ids)
                loss = ce_loss(logits, label)
            
            else:
                output = model(input_ids, labels=label)
                logits, loss = output

            prediction = torch.argmax(logits, dim=-1)
            epoch_loss += loss.item()
            if step % 10 == 0:
                sent = tokenizer.decode(input_ids[0])
                sent = re.sub('[^.-?-가-힣ㄱ-ㅎㅏ-ㅣ]','',sent).strip()
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
    optimizer='adamw',
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
    
    if optimizer == 'adamw':
        optimizer = torch.optim.AdamW(model.parameters(), lr=lr)
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
            ckpt_ = save_ckpt(
                ckpt_path = p.join(ckpt_path, f"checkpoint_epoch_{epoch +1}.pt"),
                model = model, epoch = epoch +1,
                train_loss = train_loss, best_loss = valid_loss
            )
        # Wandb logging
        wandb.log({
            "valid_loss": valid_loss
        })
        
        return ckpt_

def train_distill(
    model,
    t_model,  
    train_loader, 
    valid_loader,
    optimizer='adamw',
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
    
    if optimizer == 'adamw':
        optimizer = torch.optim.AdamW(model.parameters(), lr=lr)
    else:
        raise NotImplementedError
     
    losses = []
    train_loss = []
    best_loss = float('inf')
    model.to(device)
    t_model.to(device)   
    for epoch in range(num_epochs):
        model.train()
        t_model.eval()
        epoch_loss = 0.0
        for step, batch in enumerate(train_loader):
            input_ids, label = batch
            input_ids, label = input_ids.to(device), label.to(device)
            logits = model(input_ids)
            teacher_logits, output = t_model(input_ids)
            loss = distillation_loss(logits, label, teacher_logits)

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
        valid_loss = validate(model, valid_loader, device, tokenizer, distill=True)
        
        if valid_loss < best_loss:
            best_loss = valid_loss
            ckpt_ = save_ckpt(
                ckpt_path = p.join(ckpt_path, f"distill_checkpoint_epoch_{epoch +1}.pt"),
                model = model, epoch = epoch +1,
                train_loss = train_loss, best_loss = valid_loss
            )
        # Wandb logging
        wandb.log({
            "valid_loss": valid_loss
        })
        
        return ckpt_
      
def test(model, test_loader, device, distill=False):
    ce_loss = nn.CrossEntropyLoss()
    model.to(device)
    model.eval()
    with torch.no_grad():
        epoch_loss = 0.0
        acc_scores = 0.0
        f1_scores = 0.0
        comment = []
        labels = []
        for step, batch in enumerate(test_loader):
            input_ids, label = batch
            input_ids, label = input_ids.to(device), label.to(device)

            if distill:
                output = model(input_ids, labels=label)
                logits, loss = output
            
            else:
                logits = model(input_ids)
                loss = ce_loss(logits.view(-1,self.num_labels), label.view(-1))

            prediction = torch.argmax(logits, dim=-1)
            
            epoch_loss += loss.item()
            
            label = label.cpu()
            prediction = prediction.cpu()
            
            acc_score_ = accuracy_score(label, prediction)
            f1_score_  = f1_score(label, prediction)
            
            acc_scores += acc_score_
            f1_scores += f1_score_
            
        test_loss = epoch_loss/len(test_loader)
        test_accuracy = acc_scores/len(test_loader)*100
        test_f1_score = f1_scores/len(test_loader)

        print("Evaluation Result")
        print("Test loss : "+str(test_loss)+" | Test accuracy : "+str(test_accuracy))
        print("F1 score : "+str(test_f1_score))
        print("Finish.")

        wandb.log({
            "accuracy": test_accuracy,
            "F1 score" : test_f1_score
        })

def generate_result(model, input_sent, tokenizer, device):
    model.to(device)
    model.eval()

    input_ids = torch.tensor(tokenizer.encode(input_sent), device=device)
    output = model(input_ids.unsqueeze(0))

    try:
        logits, _ = output
    
    except:
        logits = output

    prediction = torch.argmax(logits, dim=-1)

    if int(prediction[0]) == 0:
        print(input_sent+' is not toxic sentence.')
        return 0

    else:
        print(input_sent+' is toxic sentence.')
        return 1