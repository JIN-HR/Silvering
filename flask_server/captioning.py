import torch
import torchvision.transforms as transforms
from transformers import VisionEncoderDecoderModel, ViTImageProcessor, GPT2Tokenizer
from PIL import Image
from googletrans import Translator
import time
from datetime import datetime

# 이미지 전처리
transform = transforms.Compose([
    transforms.Resize((299, 299)),
    transforms.CenterCrop((224, 224)),
    transforms.ToTensor()
])

# 모델 & 토크나이저
image_captioning_model_name = "nlpconnect/vit-gpt2-image-captioning"
image_captioning_model = VisionEncoderDecoderModel.from_pretrained(image_captioning_model_name)
feature_extractor = ViTImageProcessor.from_pretrained(image_captioning_model_name, do_rescale=False)
image_captioning_tokenizer = GPT2Tokenizer.from_pretrained(image_captioning_model_name)

translator = Translator()

# 이미지 로드 & 전처리
def load_image(image_path):
    image = Image.open(image_path).convert('RGB')
    image = transform(image).unsqueeze(0)  # 배치 차원 추가 (배치 차원 아직 완벽하게 이해 x -> 공부)
    return image

# 영어 캡션 생성
def generate_english_caption(image_path, style="as if writing a gentle diary entry for reminiscing"):
    print('캡션 생성 중')
    image_tensor = load_image(image_path)
    pixel_values = feature_extractor(images=image_tensor, return_tensors="pt").pixel_values
    attention_mask = torch.ones(pixel_values.shape[:2], dtype=torch.long)

    # 설명 길이 설정
    outputs = image_captioning_model.generate(
        pixel_values,
        attention_mask=attention_mask,
        max_length=50,
        min_length=30,
        num_beams=5,    # 빔 수
        length_penalty=1.0,  # 길이 페널티
        no_repeat_ngram_size=2,  # 중복 단어 생성 방지
        early_stopping=True  # 설명 길면 stop!
    )

    english_caption = image_captioning_tokenizer.batch_decode(outputs, skip_special_tokens=True)[0]
    return english_caption

# 영->한 번역
def translate_to_korean(english_caption):
    translated = translator.translate(english_caption, src='en', dest='ko')
    return translated.text
def generate_korean_caption(image_path, year, month, day):
    start_time = time.time()
    korean_caption = "캡션 생성에 실패했습니다."  # 초기값 설정 (오류 발생 시 대비)
    runtime = 0  # 기본값 설정

    try:
        # 캡션 생성
        english_caption = generate_english_caption(image_path)

        # 몇 년 전
        current_year = datetime.now().year
        current_month = datetime.now().month
        current_day = datetime.now().day


        if current_year == int(year):
            if current_month == int(month):
                if current_day == int(day):
                    time_ago = "today"
                else:
                    time_ago = f"{current_day - int(day)} days ago"
            else:
                time_ago = f"{current_month - int(month)} months ago"
        else:
            time_ago = f"{current_year - int(year)} years ago"

        # 영어 캡션 생성
        english_caption = f"Do you remember? This photo was taken {time_ago} ago, and as you see, there is " + english_caption

        # 영어 -> 한국어 번역
        korean_caption = translate_to_korean(english_caption)
        end_time = time.time()
        runtime = end_time - start_time

        # 로그 출력
        print(f"영어 캡션: {english_caption}")
        print(f"한국어 캡션: {korean_caption}")
        print(f"실행 시간: {runtime:.2f}초")
    except Exception as e:
        print(f"오류 발생: {e}")

    return korean_caption, runtime
