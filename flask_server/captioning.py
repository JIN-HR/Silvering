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
    image = Image.open(image_path).convert("RGB")
    return image


# 이미지를 Base64로 인코딩하는 함수
def encode_image(image_path):
    with open(image_path, "rb") as image_file:
        return base64.b64encode(image_file.read()).decode("utf-8")


# 저장 딕셔너리
state = {"caption": None, "user_response": None, "expanded_diary": None}


# 일기 초안, 질문 생성
def generate_initial_caption(image_path, year, month, day):
    start_time = time.time()
    caption = "캡션 생성에 실패했습니다."  # 초기값 설정
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
    custom_prompt = f"{time_ago}에 촬영된 사진입니다. 사진을 회상하는 1인칭 형식의 한국어 일기의 첫 문단만 작성해 주세요. 이때, 사진이 찍힌 날짜를 현재로부터 얼마 전인지 자연스럽게 포함시켜 작성해주세요. 다음, 일기 뒤에 한 줄을 띄우고 이 사진과 관련한 질문을 생성해야 합니다. 사용자는 고령의 노인으로, 이해하기 쉬운 질문을 해야합니다. 예를 들어, '사진을 찍은 날 기분은 어땠나요?', '사진을 찍은 후 무엇을 했나요?'와 같은 짧은 질문 하나를 생성해주세요."
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {openai.api_key}",
    }
    payload = {
        "model": "gpt-4o",
        "messages": [
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": custom_prompt},
                    {
                        "type": "image_url",
                        "image_url": {"url": f"data:image/jpeg;base64,{base64_image}"},
                    },
                ],
            }
        ],
        "max_tokens": 300,
    }

    # OpenAI API에 POST 요청
    try:
        response = requests.post(
            "https://api.openai.com/v1/chat/completions", headers=headers, json=payload
        )
        response.raise_for_status()  # HTTP 오류 발생 시 예외 발생

        response_json = response.json()
        if "choices" in response_json and response_json["choices"]:
            content = response_json["choices"][0]["message"]["content"]
            caption = content  # 캡션을 caption에 저장
        else:
            print("Error in response:", response_json)

        # 실행 시간 계산
        runtime = time.time() - start_time
        print(f"생성된 한국어 캡션: {caption}")
        print(f"실행 시간: {runtime:.2f}초")

    except requests.RequestException as e:
        print(f"API 요청 실패: {e}")

    # 캡션과 실행 시간 반환
    state["caption"] = caption
    return caption, runtime


# 일기 마무리
def expand_diary(caption, user_response):
    state["user_response"] = user_response

    start_time = time.time()
    expanded_diary = "일기 생성에 실패했습니다."  # 초기값 설정
    runtime = 0  # 기본값 설정

    # 설명 요청을 위한 payload 구성
    custom_prompt = f"입력된 정보를 사용해서 한국어 일기의 두 번째 문단을 이어서 작성해야 해. 사용자는 고령의 노인이고, 일기의 첫 문단은 사용자가 직접 찍은 사진을 기반해서 아까 생성해준 일기고 질문은 그 일기와 관련된 질문이야."
    headers = {
        "Content-Type": "application/json",
        "Authorization": f"Bearer {openai.api_key}",
    }
    payload = {
        "model": "gpt-4o",
        "messages": [
            {"role": "system", "content": custom_prompt},
            {
                "role": "assistant",
                "content": f"일기 첫 번째 문단과 관련 질문: {state['caption']}",
            },
            {"role": "user", "content": f"사용자의 응답: {state['user_response']}"},
            {
                "role": "assistant",
                "content": "두 입력 값을 참고해서 연관있는 회상 일기를 이어서 생성해줘. 사용자의 응답이 없거나 애매할 때에는 그냥 일기 첫 문단만 참고해서 간단하게 작성해줘",
            },
        ],
        "max_tokens": 500,
    }

    # OpenAI API에 POST 요청
    try:
        response = requests.post(
            "https://api.openai.com/v1/chat/completions", headers=headers, json=payload
        )
        response.raise_for_status()  # HTTP 오류 발생 시 예외 발생

        response_json = response.json()
        if "choices" in response_json and response_json["choices"]:
            content = response_json["choices"][0]["message"]["content"]
            expanded_diary = content
        else:
            print("Error in response:", response_json)

        # 실행 시간 계산
        runtime = time.time() - start_time
        print(f"생성된 일기: {expanded_diary}")
        print(f"실행 시간: {runtime:.2f}초")

    except requests.RequestException as e:
        print(f"API 요청 실패: {e}")

    # 캡션과 실행 시간 반환
    state["expanded_diary"] = expand_diary
    return expanded_diary, runtime
