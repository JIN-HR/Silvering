from transformers import AutoTokenizer, AutoModelForSequenceClassification
import torch
import datetime

# MobileBERT 모델 로드
MODEL_NAME = "google/mobilebert-uncased"
tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)
model = AutoModelForSequenceClassification.from_pretrained(MODEL_NAME, num_labels=2)

# 현재 날짜와 시간
now = datetime.datetime.now()
year = now.year
month = now.month
day = now.day
weekdays = ["월요일", "화요일", "수요일", "목요일", "금요일", "토요일", "일요일"]
weekday = weekdays[now.weekday()]

# 문제별 정답 데이터
correct_answers = {
    1: [str(year), f"{year}년"],  # 연도
    3: ["6-9-7-3", "5-7-2-8-4"],  # 숫자열
    4: ["산강수금"],  # 거꾸로 말하기
    8: ["민수", "자전거", "공원", "11시", "야구"]  # 문장 기억
}

def eval_response(user_text, question_number):
    """
    MobileBERT 모델을 사용하여 사용자 응답을 평가합니다.
    Args:
        user_text (str): 사용자 응답 텍스트
        question_number (int): 문제 번호
    Returns:
        int: 평가 결과 (0: 틀림, 1: 맞음)
    """
    # 정답 데이터 가져오기
    if question_number not in correct_answers:
        print(f"Error: 문제 번호 {question_number}에 대한 정답 데이터가 없습니다.")
        return 0

    answers = correct_answers[question_number]

    for answer in answers:
        prompt = f"사용자 응답: {user_text}\n정답: {answer}\n응답이 정확하면 1, 아니면 0을 반환하세요."

        # MobileBERT 입력 생성
        inputs = tokenizer(prompt, return_tensors="pt", truncation=True, padding=True, max_length=128)

        # MobileBERT 예측
        with torch.no_grad():
            outputs = model(**inputs)
            logits = outputs.logits
            predicted_class = torch.argmax(logits).item()

        # 정답 일치 시 1 반환
        if predicted_class == 1:
            print(f"MobileBERT 예측 결과: {predicted_class} (일치: {answer})")
            return 1

    # 모든 정답 불일치 시 0 반환
    print("MobileBERT 예측 결과: 0")
    return 0

# 테스트
if __name__ == "__main__":
    test_cases = [
        {"user_text": "2024년", "question_number": 1},  # 연도
        {"user_text": "6-9-7-3", "question_number": 3},  # 숫자열
        {"user_text": "산강수금", "question_number": 4},  # 거꾸로 말하기
        {"user_text": "민수는 자전거를 타고 공원에 갔다", "question_number": 8},  # 문장 기억
    ]

    for case in test_cases:
        user_text = case["user_text"]
        question_number = case["question_number"]
        print(f"\n문제 {question_number}: '{user_text}'")
        result = eval_response(user_text, question_number)
        print(f"평가 결과: {result}")
