import requests
    
while True:
    text = input()
    response1 = requests.post("http://119.194.17.59:8080/predictions/classification1", json={'text': text})
    response2 = requests.post("http://119.194.17.59:8888/predictions/classification2", json={'text': text})
    response3 = requests.post("http://119.194.17.59:8080/predictions/classification3", json={'text': text})

    print(response1.text, response2.text, response3.text)

    r1 = int(response1.text)
    r2 = int(response2.text)
    r3 = 0

    if response3.text == "clean":
        r3 = 0
    else:
        r3 = 1
        
    if (r1 + r2 + r3 >= 2):
        print("toxic")
    else:
        print("not toxic")
    print()
    
    # text = input()
    # response = requests.post("http://119.194.17.59:8080/predictions/summarization", json={'text': text})

    # print(response.text)
    # print()