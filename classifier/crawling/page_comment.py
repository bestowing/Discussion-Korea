from selenium import webdriver
from bs4 import BeautifulSoup
import time

def click_more(driver, delay_time):
    while True:
        
        try: 
            driver.find_element_by_css_selector('div.u_cbox_view_comment a.u_cbox_btn_view_comment').click()
            time.sleep(delay_time)
            
        except:
            break
        
        try:
            more = driver.find_element_by_css_selector('a.u_cbox_btn_more')
            more.click()
            time.sleep(delay_time)
            
        except:
            break

def crawling_comment(url, wait_time=5, delay_time=0.1):
    
    options = webdriver.ChromeOptions()
    options.add_argument("headless")
    driver = webdriver.Chrome('./chromedriver', options=options)
    driver.implicitly_wait(wait_time)
    driver.get(url)
        
    click_more(driver, delay_time)
    
    html = driver.page_source
    soup = BeautifulSoup(html, 'lxml') 
    contents = soup.select('span.u_cbox_contents')
    ls1 = [content.text for content in contents]

    #driver.find_element_by_css_selector("a.u_cbox_cleanbot_setbutton").click()
    
    try:
        button = driver.find_element_by_xpath('//*[@id="cbox_module"]/div[2]/div[7]/a')
        driver.execute_script("arguments[0].click();", button)
        driver.find_element_by_css_selector("input#cleanbot_dialog_checkbox_cbox_module").click()
        #print("cbox module ok")  
        driver.find_element_by_css_selector("button.u_cbox_layer_cleanbot2_extrabtn").click()
        click_more(driver, delay_time)
      
    except:
        print('There is no button in '+url)
        
    html = driver.page_source
    soup = BeautifulSoup(html, 'lxml') 
    contents2 = soup.select('span.u_cbox_contents')
    ls2 = [content.text for content in contents2]

                    
    if len(ls2) < len(ls1):
        filter_comment_list = ls2
        all_comment_list = ls1
            
    else:
        filter_comment_list = ls1
        all_comment_list = ls2
        
    driver.quit()

    return filter_comment_list, all_comment_list
