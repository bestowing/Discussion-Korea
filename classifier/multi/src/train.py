import os
import os.path as p
import re
from tqdm import tqdm_notebook
import wandb
import numpy as np
import torch
import torch.nn as nn
import torch.nn.functional as F
from sklearn.metrics import f1_score, accuracy_score, precision_score, recall_score

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
    student_loss = ce_loss(logits.view(-1,2), labels.view(-1))
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
    tokenizer=None,
    alpha = 0.6
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
        for step, batch in tqdm_notebook(enumerate(train_loader)):
            # (sent, kind_label, toxic_label)
            input_ids, label = batch
            input_ids, label = input_ids.to(device), label.to(device)
            output = model(input_ids, labels=label, device=device)
            # logits, output, kind_loss, toxic_loss
            _, _, kind_loss, toxic_loss = output
            
            loss = (1-alpha) * kind_loss + alpha * toxic_loss
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
        
        if valid_loader is not None:
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
        
        if valid_loader is None:
            ckpt_ = save_ckpt(
                ckpt_path= p.join(ckpt_path, f"multi-label_checkpoint_epoch_{epoch +1}.pt"),
                model = model, epoch = epoch +1,
                train_loss = train_loss, best_loss = train_loss
            )
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
      
def test(model, test_loader, device, distill=False, multi_label=False):
    ce_loss = nn.CrossEntropyLoss()
    model.to(device)
    model.eval()
    with torch.no_grad():
        epoch_loss = 0.0
        acc_scores = 0.0
        f1_scores = 0.0
        recall_scores = 0.0
        precision_scores = 0.0
        
        comment = []
        labels = []
        for step, batch in enumerate(test_loader):
            input_ids, label = batch
            input_ids, label = input_ids.to(device), label.to(device)

            if not distill:
                output = model(input_ids, labels=label)
                logits, loss = output
            
            else:
                logits = model(input_ids)
                loss = ce_loss(logits.view(-1,2), label.view(-1))

            prediction = torch.argmax(logits, dim=-1)
            
            epoch_loss += loss.item()
            
            label = label.cpu()
            prediction = prediction.cpu()
            
            if multi_label is False:
                acc_score_ = accuracy_score(label, prediction)
                f1_score_  = f1_score(label, prediction)
                precision_score_  = precision_score(label, prediction)            
                recall_score_  = recall_score(label, prediction)            
            
            if multi_label:
                acc_score_ = accuracy_score(label, prediction, average="micro")
                f1_score_  = f1_score(label, prediction, average="micro")
                precision_score_  = precision_score(label, prediction, average="micro")            
                recall_score_  = recall_score(label, prediction, average="micro")   
                
            acc_scores += acc_score_
            f1_scores += f1_score_
            precision_scores += precision_score_
            recall_scores += recall_score_
            
        test_loss = epoch_loss/len(test_loader)
        test_accuracy = acc_scores/len(test_loader)*100
        test_f1_score = f1_scores/len(test_loader)
        test_recall_score = recall_scores/len(test_loader)
        test_precision_score = precision_scores/len(test_loader)

        print("Evaluation Result")
        print("Test loss : "+str(test_loss)+" | Test accuracy : "+str(test_accuracy))
        print("F1 score : "+str(test_f1_score))
        print("precision score : "+str(test_precision_score))
        print("recall score : "+str(test_recall_score))
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

def generate_multi_result(model, input_sent, tokenizer, device, type=1):
    target = ["여성/가족", "남성", "성소수자", "인종/국적", "연령", "지역", "종교", "혐오", "욕설", "clean", "개인지칭"]

    model.to(device)
    model.eval()

    input_ids = torch.tensor(tokenizer.encode(input_sent), device=device)
    output = model(input_ids.unsqueeze(0))

    if type==2:
        kind, clean, _, _ = output
        
        prediction_kind = torch.topk(kind,1)
        prediction_kind.values
        p = torch.nn.functional.softmax(kind, dim=1)
        #print(p)
        prediction_clean = torch.argmax(clean, dim=-1)
        p2 = torch.nn.functional.softmax(clean, dim=1)
        #print(p2)
        if int(prediction_clean[0]) == 1:
            type = list(prediction_kind.indices[0])[0]
            if type == 8 or type ==7:
                print("해당 댓글은 clean한 댓글입니다.")
            else:
                print("해당 댓글은 "+target[list(prediction_kind.indices[0])[0]]+"에 해당하는 clean한 댓글입니다.")
        
        else:
            print("해당 댓글은"+str(int(p2[prediction_clean[0]][0]*100))+"% 확률로 비방성 표현이며")
            print("해당 댓글은 "+target[list(prediction_kind.indices[0])[0]]+"에 관한 내용입니다.")
    
    else:
        logits, _ = output
        
        prediction = torch.argmax(logits, dim=-1)
        #여성/가족	남성	성소수자	인종/국적	연령	지역	종교	기타 혐오	악플/욕설	clean	개인지칭
        # label toxic 하나로 합치기 
        # 아니면 모델 두개로 만들기?
        #if prediction == 9:
        #    print("바른 언어를 사용하시네요.")
        
        #else:
        include_list = []
        topk = torch.topk(logits, 2)
        indices = list(topk.indices[0])
        
        if 9 in indices:
            all_type = None
            for type in indices:
                if type != 9 and type != 8 and type !=7:
                    all_type = target[type]  
                    text = "해당 댓글은 "+all_type+"에 해당하는 표현이며, clean한 댓글 입니다."
                    print(text)
            if all_type is None:
                text = "해당 댓글은 clean한 댓글 입니다."
                print(text)
        
        else:   
            p = torch.nn.functional.softmax(logits, dim=1)*100
            p = p[0][int(indices[0])]
            text = "해당 댓글은 "+str(int(p))+"% 의 확률로 "+target[indices[0]]+"에 해당하는 비방성 댓글 입니다."
            print(text)
    return text