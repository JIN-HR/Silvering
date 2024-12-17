from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
import datetime

# 학습된 MobileBERT 모델 로드
MODEL_PATH = "mobilebert_fewshot"  # 학습된 모델 디렉토리
tokenizer = AutoTokenizer.from_pretrained(MODEL_PATH)
model = AutoModelForSequenceClassification.from_pretrained(MODEL_PATH)
model.eval()

# 현재 날짜와 시간
now = datetime.datetime.now()
year = now.year
month = now.month
day = now.day
weekdays = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]
weekday = weekdays[now.weekday()]

# 문제별 정답 데이터
correct_answers = {
    1: [str(year), f"{year}년", f"{month}월", f"{day}일", weekday],  # 문제 1: 날짜와 요일
    3: ["6-9-7-3", "5-7-2-8-4"],  # 문제 3: 숫자열
    4: ["산강수금"],  # 문제 4: 거꾸로 말하기
    8: ["민수", "자전거", "공원", "11시", "야구"]  # 문제 8: 문장 기억
}

# 기존 eval_response 함수 수정
def eval_response(user_text, question_number):
    """
    MobileBERT 모델을 사용하여 사용자 응답을 평가합니다.
    Args:
        user_text (str): 사용자 응답 텍스트
        question_number (int): 문제 번호
    Returns:
        int: 평가 결과 (0: 틀림, 1: 맞음)
    """
    if question_number not in correct_answers:
        print(f"Error: 문제 번호 {question_number}에 대한 정답 데이터가 없습니다.")
        return 0

    answers = correct_answers[question_number]

    for answer in answers:
        # MobileBERT 입력 생성
        inputs = tokenizer(answer, user_text, return_tensors="pt", truncation=True, padding=True, max_length=128)

        # MobileBERT 예측
        with torch.no_grad():
            outputs = model(**inputs)
            logits = outputs.logits
            predicted_class = torch.argmax(logits).item()

        # 정답일 경우 1 반환
        if predicted_class == 1:
            return 1

    # 모든 정답과 비교해도 맞는 것이 없으면 0 반환
    return 0
