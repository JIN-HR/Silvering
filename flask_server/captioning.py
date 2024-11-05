import openai
import os
import base64
from dotenv import load_dotenv
from PIL import Image
import time
from datetime import datetime
import requests

# OPENAI API KEY
load_dotenv()
openai.api_key = os.getenv("OPENAI_API_KEY")

# 이미지 로드 및 전처리 함수
def load_image(image_path):
    image = Image.open(image_path).convert('RGB')
    return image

# 이미지를 Base64로 인코딩하는 함수
def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode('utf-8')

# GPT-4 Vision을 사용하여 한국어 일기 형식 캡션 생성
def generate_korean_caption(image_path, year, month, day):
    start_time = time.time()
    korean_caption = "캡션 생성에 실패했습니다."  # 초기값 설정
    runtime = 0  # 기본값 설정

    # 날짜 계산
    current_year = datetime.now().year
    current_month = datetime.now().month
    current_day = datetime.now().day

    # 날짜 차이 계산
    if current_year == int(year):
        if current_month == int(month):
            if current_day == int(day):
                time_ago = "오늘"
            else:
                time_ago = f"{current_day - int(day)}일 전"
        else:
            time_ago = f"{current_month - int(month)}개월 전"
    else:
        time_ago = f"{current_year - int(year)}년 전"

    # 이미지 Base64 인코딩
    base64_image = encode_image(image_path)

    # 설명 요청을 위한 payload 구성
    custom_prompt = (
        f"{time_ago}에 촬영된 사진입니다. 이 사진이 찍힌 시기와 함께 사진에 대해 일기 형식의 설명을 한국어로 작성해 주세요."
    )
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {openai.api_key}"
    }
    payload = {
        "model": "gpt-4o",
        "messages": [
            {
                "role": "user",
                "content": [
                    {
                        "type": "text",
                        "text": custom_prompt
                    },
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:image/jpeg;base64,{base64_image}"
                        }
                    }
                ]
            }
        ],
        "max_tokens": 1000
    }

    # OpenAI API에 POST 요청
    try:
        response = requests.post("https://api.openai.com/v1/chat/completions", headers=headers, json=payload)
        response.raise_for_status()  # HTTP 오류 발생 시 예외 발생

        response_json = response.json()
        if "choices" in response_json and response_json['choices']:
            content = response_json['choices'][0]['message']['content']
            korean_caption = content  # 캡션을 korean_caption에 저장
        else:
            print("Error in response:", response_json)

        # 실행 시간 계산
        runtime = time.time() - start_time
        print(f"생성된 한국어 캡션: {korean_caption}")
        print(f"실행 시간: {runtime:.2f}초")

    except requests.RequestException as e:
        print(f"API 요청 실패: {e}")

    # 캡션과 실행 시간 반환
    return korean_caption, runtime
