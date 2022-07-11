import requests
    
while True:
    try:
        requests.post("http://119.194.17.59:8080/ping")
    except:
        print("Failed to connect model server.")
        break
    
    mode = input("Classification or Summarization? (c/s): ")
    
    if mode == "c":
        text = input("Input yout text for classification:\n")
        response1 = requests.post("http://119.194.17.59:8080/predictions/classification1", json={'text': text})
        response2 = requests.post("http://119.194.17.59:8888/predictions/classification2", json={'text': text})
        response3 = requests.post("http://119.194.17.59:8080/predictions/classification3", json={'text': text})

        r1 = int(response1.text)
        r2 = int(response2.text)
        r3 = 0

        if response3.text == "clean":
            r3 = 0
        else:
            r3 = 1
            
        if (r1 + r2 + r3 >= 2):
            print("Your text is toxic.")
            print("[ classification1: " + response1.text, "  classification2: " + response2.text, "  classification3: " + response3.text + " ]")
        else:
            print("Your text is not toxic.")
            print("[ classification1: " + response1.text, "  classification2: " + response2.text, "  classification3: " + response3.text + " ]")
        print()
        
    elif mode == "s":
        text = input("Input yout text for summarization:\n")
        response = requests.post("http://119.194.17.59:8080/predictions/summarization", json={'text': text})

        print("Your summarization is:")
        print(response.text)
        print()
    
    else:
        print("Try again.")