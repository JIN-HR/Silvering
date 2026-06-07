# Silvering | 치매 노인과 보호자를 위한 통합 어플리케이션

고령자(피보호자)의 인지 건강을 모니터링하고 보호자가 원격으로 돌볼 수 있도록 지원하는 Flutter 모바일 애플리케이션입니다.

---

## 주요 기능

### 피보호자 (Dependent)
- **인지 검사**: MobileBERT 기반 AI 모델로 음성 응답을 평가하는 인지 기능 검사
- **두뇌 게임**: 언어, 수학, 기억력, 패턴 인식 등 다양한 두뇌 훈련 게임
- **AI 일기 쓰기**: 사진을 업로드하면 GPT-4o가 회상 일기 초안을 생성하고, 사용자의 음성 응답을 반영해 완성

### 보호자 (Guardian)
- **실시간 위치 확인**: Socket.IO를 통한 피보호자 실시간 위치 모니터링
- **안전 구역 설정**: 피보호자의 허용 이동 범위 설정
- **일기 확인**: 피보호자가 작성한 일기 열람
- **인지 검사 결과 확인**: 검사 결과 이력 조회
- **채팅**: 보호자-피보호자 간 실시간 채팅

---

## 기술 스택

| 구분 | 기술 |
|------|------|
| 모바일 앱 | Flutter (Dart) |
| 인증 / DB | Firebase Auth, Cloud Firestore |
| 백엔드 서버 | Python Flask + Flask-SocketIO |
| AI - 일기 생성 | OpenAI GPT-4o (Vision) |
| AI - 인지 평가 | MobileBERT (Few-shot fine-tuned) |
| 위치 서비스 | Google Maps Flutter, Geolocator |
| 음성 | Flutter TTS / STT |

---

## 프로젝트 구조

```
Silvering/
├── lib/                        # Flutter 앱 소스
│   ├── main.dart               # 앱 진입점, 역할 기반 라우팅
│   ├── login.dart              # 로그인 화면
│   ├── auth_service.dart       # Firebase 인증 서비스
│   ├── pages/
│   │   ├── dependantPages/     # 피보호자 화면
│   │   │   ├── dependentHome.dart
│   │   │   ├── test.dart       # 인지 검사
│   │   │   ├── diary.dart      # AI 일기
│   │   │   ├── game.dart       # 두뇌 게임 목록
│   │   │   └── gamePage/       # 게임별 화면
│   │   └── guardianPages/      # 보호자 화면
│   │       ├── guardianHome.dart
│   │       ├── location.dart   # 위치 확인
│   │       ├── set_location.dart
│   │       ├── diaryCheck.dart
│   │       ├── testCheck.dart
│   │       └── chat.dart
├── flask_server/               # AI 백엔드 서버
│   ├── app.py                  # Flask 메인 서버
│   ├── captioning.py           # GPT-4o 일기 생성
│   ├── test_eval.py            # MobileBERT 인지 평가
│   └── mobilebert_fewshot/     # 학습된 MobileBERT 모델
└── assets/fonts/               # 커스텀 폰트 (나눔, GmarketSans)
```

---

## 시작하기

### 사전 준비

- Flutter SDK 3.4.3 이상
- Python 3.10 이상
- Firebase 프로젝트 (Authentication, Firestore 활성화)
- OpenAI API 키

### Flutter 앱 실행

```bash
flutter pub get
flutter run
```

### Flask 서버 실행

```bash
cd flask_server
pip install flask flask-cors flask-socketio flask-login firebase-admin python-dotenv openai torch transformers pillow eventlet
```

`.env` 파일을 `flask_server/` 에 생성합니다:

```env
OPENAI_API_KEY=your_openai_api_key
FIREBASE_CERTIFICATE=path/to/serviceAccountKey.json
# 또는 JSON 내용을 직접 입력
```

```bash
python app.py
```

서버는 `http://0.0.0.0:5000` 에서 실행됩니다.

---

## API 엔드포인트

| 메서드 | 경로 | 설명 |
|--------|------|------|
| POST | `/generate_caption` | 이미지로 일기 초안 및 질문 생성 |
| POST | `/generate_expand_diary` | 사용자 응답을 반영해 일기 완성 |
| POST | `/evaluate` | 인지 검사 답변 평가 |
| GET  | `/get_user_role` | Firestore에서 사용자 역할 조회 |
| POST | `/add_user` | 신규 사용자 등록 |

---

## 환경 설정 주의사항

- `android/app/google-services.json` — Firebase 설정 파일 (`.gitignore` 에 포함됨)
- Firebase 서비스 계정 키(`.json`)는 절대 커밋하지 않습니다
- `lib/firebase_options.dart` 는 `flutterfire configure` 로 생성합니다
