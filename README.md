<img width="100%" alt="방구석 대한민국" src="https://user-images.githubusercontent.com/59321616/171611106-442b5a0e-06d1-4f05-9445-92c9b8e70b05.png">

<p align="center">
    <img src="https://img.shields.io/badge/Swift-v5.0-red?logo=swift" />
    <img src="https://img.shields.io/badge/Xcode-v13.3-blue?logo=Xcode" />
    <img src="https://img.shields.io/badge/iOS-13.0+-black?logo=apple" />  
</p>

# 방구석 대한민국 (Virtual Korea)
This is a new concept discussion platform introducing AI host. We have developed a discussion platform centered on a fair AI host capable of offensive comment masking and summarizing discussion content. 

**This repository contains the source code of the Team A of Capstone Design Project at SKKU (Spring 2022).**

## Contributors
    |name|contribute|responsible folder|
    |------|---|---|
    |Kim Seok|model serving|made ./server folder|
    |Park Jinwoo|summarization model|made ./summarization folder|
    |Lee Chungsoo|application dev|made ./Discussion-Korea and ./Discussion-Korea-Backend folder|
    |Jang Chaeyoon|offensive comment classifier| made ./classifier folder|


## File Structure
If you want to make your own AI host, please check the ./classifier and ./summarization folder.
```
./classifier
  ./multi
    ./src
    ├── main.py - main 
    ├── model.py - contain all models
    ├── train.py - train/eval/test
    ...
    └── utils - utilities
        ├── dataset.py - dataset & dataloader 
        ├── preprocessing.py - dataset preprocessing & save
        ...
  ./binary
  ...
  ./crawling
    ├── main.py - main 
    ...
```
If you want to check the application code, please check the ./app folder.

## How to use and Demo
<p align="center">
    <img width="100%" height="100%" alt="어플 아키텍쳐" src="https://user-images.githubusercontent.com/67726968/171690436-753e2566-c5fc-4b0e-bfd1-5238e95963eb.png">
</p>

## Referneces
[1] Park, Sungjoon, et al. "Klue: Korean language understanding evaluation.", arXiv preprint arXiv:2105.09680, (2021).

[2] Liu, Yinhan, et al. "RoBERTa: A Robustly Optimized BERT Pretraining Approach.", arXiv preprint arXiv:1907.11692, (2019).

[3] Sun, Chi, et al. "How to fine-tune bert for text classification?." China national conference on Chinese computational linguistics., (2019).

[4] Mike Lewis, et al. "Bart: Denoising sequence-tosequence pre-training for natural language generation, translation, and comprehension.", arXiv preprint arXiv:1910.13461, (2019).

## OpenSource License

- [Firebase (Apache 2.0)](https://github.com/firebase/firebase-ios-sdk/blob/master/LICENSE)
- [Kingfisher (MIT)](https://github.com/onevcat/Kingfisher/blob/master/LICENSE)
- [RxKeyboard (MIT)](https://github.com/RxSwiftCommunity/RxKeyboard/blob/master/LICENSE)
- [RxSwift (MIT)](https://github.com/ReactiveX/RxSwift/blob/main/LICENSE.md)
- [SideMenu (MIT)](https://github.com/jonkykong/SideMenu/blob/master/LICENSE)
- [SnapKit (MIT)](https://github.com/SnapKit/SnapKit/blob/develop/LICENSE)
