import torch
import torchvision.transforms as transforms
from transformers import VisionEncoderDecoderModel, ViTImageProcessor, GPT2Tokenizer
from PIL import Image
from googletrans import Translator
import time

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
def generate_english_caption(image_path):
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

# 캡션 생성
def generate_korean_caption(image_path):
    start_time = time.time()
    english_caption = generate_english_caption(image_path)
    korean_caption = translate_to_korean(english_caption)
    end_time = time.time()
    runtime = end_time - start_time
    return korean_caption, runtime
