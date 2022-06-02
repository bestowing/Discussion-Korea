import requests
from bs4 import BeautifulSoup
from page_comment import crawling_comment
from tqdm import tqdm

def crawling_link(url):
    headers = {"User-Agent":"Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/90.0.4430.93 Safari/537.36"}
    res = requests.get(url, headers=headers)
    res.raise_for_status() 
    soup = BeautifulSoup(res.text, "lxml") 

    rankingnews_boxs = soup.select('#wrap > div.rankingnews._popularWelBase._persist > div.rankingnews_box_wrap._popularRanking > div > div')

    filter_comment_list = []
    all_comment_list = []

    for rankingnews_box in rankingnews_boxs:
        rankingnews_lists = rankingnews_box.select('ul > li')
        for rankingnews_list in tqdm(rankingnews_lists):   
            title = rankingnews_list.find('a')['href']
            fl, al = crawling_comment(title)
            filter_comment_list += fl
            all_comment_list += al
    
    return filter_comment_list, all_comment_list