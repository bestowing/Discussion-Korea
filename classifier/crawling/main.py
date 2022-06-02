import pandas as pd
from tqdm import tqdm_notebook
from page_link import crawling_link


main_url = "https://news.naver.com/main/ranking/popularMemo.naver?date="

# set date index of starting and ending
dt_index = pd.date_range(start='20210101', end='20220324')
dt_list = dt_index.strftime("%Y%m%d").tolist()

clean = []
all = []
for date in tqdm_notebook(dt_list):
    url = main_url + str(date)
    filter_comment_list, all_comment_list = crawling_link(url)
    clean += filter_comment_list
    all += all_comment_list

df1 = pd.DataFrame()
df2 = pd.DataFrame()

df1['clean comment'] = clean
df2['all comment'] = all

df1.to_csv('clean_comment.csv')
df2.to_csv('all_comment.csv')