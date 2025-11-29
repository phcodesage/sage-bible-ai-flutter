import requests
import json

API_KEY = "e49cf83d372e4d02a6ee775553c16901"
BASE_URL = "https://api.aimlapi.com/v1"

def test_api():
    url = f"{BASE_URL}/chat/completions"
    headers = {
        "Authorization": f"Bearer {API_KEY}",
        "Content-Type": "application/json"
    }
    
    # Using a common model like gpt-3.5-turbo or similar that AIML API usually supports
    # If this fails, we might need to check available models endpoint
    payload = {
        "model": "gpt-3.5-turbo",
        "messages": [
            {"role": "user", "content": "What does John 3:16 say?"}
        ],
        "max_tokens": 50
    }

    print(f"Testing API at {url}...")
    try:
        response = requests.post(url, headers=headers, json=payload)
        print(f"Status Code: {response.status_code}")
        
        if response.status_code == 200:
            print("Success!")
            print("Response:")
            print(json.dumps(response.json(), indent=2))
        else:
            print("Failed.")
            print("Response:")
            print(response.text)
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    test_api()
