from flask import Flask, request, jsonify
from flask_cors import CORS
from captioning import generate_initial_caption, expand_diary
from flask_socketio import SocketIO, join_room, leave_room
from flask_login import login_manager, login_user, login_required, current_user
from test_eval import eval_response

# login
import firebase_admin
from firebase_admin import credentials, firestore, auth

# firebase certificate
import os, json
from dotenv import load_dotenv

# CORS 설정
app = Flask(__name__)
CORS(app, resources={r"/generate_caption": {"origins": "*"}})  # origin allow
CORS(app, resources={r"/evaluate": {"origins": "*"}})  # origin allow



# Firebase 초기화
# .env 파일 로드
load_dotenv()

# FIREBASE_CERTIFICATE에서 값 읽기
firebase_cert = os.getenv("FIREBASE_CERTIFICATE")

# 방법 1: 경로 사용
if firebase_cert.endswith(".json"):  # 파일 경로인 경우
    cred = credentials.Certificate(firebase_cert)

# 방법 2: JSON 내용 사용
else:
    cert_dict = json.loads(firebase_cert)  # 문자열을 딕셔너리로 변환
    cred = credentials.Certificate(cert_dict)

firebase_admin.initialize_app(cred)


# Firestore 참조 생성
db = firestore.client()


class User:
    def __init__(self, username, role):
        self.username = username
        self.role = role

    def is_authenticated(self):
        return True

    def get_id(self):
        return self.username


### 기능 A
@app.route("/evaluate", methods=["POST"])
def evaluate():
    # 클라이언트로부터 JSON 데이터 받기
    data = request.get_json()  # 안전하게 JSON 데이터를 파싱합니다.

    if not data or "text" not in data or "question_number" not in data:
        return jsonify({"error": "Invalid data provided"}), 400

    user_text = data["text"]
    question_number = data["question_number"]  # question_number 값을 받음

    # 평가 함수 호출
    evaluation = eval_response(user_text, question_number)

    # 응답 반환
    return jsonify({"evaluation": evaluation})

    # 평가 함수 호출 (예제로 eval_response_1을 사용)
    evaluation = eval_response(user_text, question_number)

    # 응답 반환
    return jsonify({"evaluation": evaluation})


# 일기 초안 생성
@app.route("/generate_caption", methods=["POST"])
def generate_caption():
    if "image" not in request.files:
        return jsonify({"error": "이미지가 선택되지 않았습니다."}), 400

    image = request.files["image"]
    image_path = "./temp_image.jpg"
    image.save(image_path)

    # 날짜 데이터
    year = request.form.get("year")
    month = request.form.get("month")
    day = request.form.get("day")

    # 서버 전송 확인
    print(f"app.py - Year: {year}, Month: {month}, Day: {day}")

    caption, runtime = generate_initial_caption(image_path, year, month, day)
    print("app.py - ", caption)

    return jsonify({"caption": caption, "runtime": runtime})


# 일기 완성
@app.route("/generate_expand_diary", methods=["POST"])
def generate_expand_diary():
    caption = request.form.get("caption")
    user_response = request.form.get("user_response")

    expanded_diary, runtime = expand_diary(caption, user_response)
    return jsonify({"expanded_diary": expanded_diary, "runtime": runtime})


##login
@app.route("/get_user_role", methods=["GET"])
def get_user_role():
    user_id = request.args.get("userId")
    if not user_id:
        return jsonify({"error": "Missing userId"}), 400

    try:
        # Firestore에서 사용자 역할 조회
        user_doc = db.collection("users").document(user_id).get()
        if user_doc.exists:
            user_data = user_doc.to_dict()
            return jsonify({"role": user_data.get("role")})
        else:
            return jsonify({"error": "User not found"}), 404
    except Exception as e:
        return jsonify({"error": str(e)}), 500


@app.route("/add_user", methods=["POST"])
def add_user():
    data = request.get_json()
    if not data or "userId" not in data or "role" not in data:
        return jsonify({"error": "Invalid data"}), 400

    user_id = data["userId"]
    role = data["role"]
    guardian_id = data.get("guardianId")  # 피보호자일 경우 보호자 ID

    try:
        user_data = {
            "role": role,
            "createdAt": firestore.SERVER_TIMESTAMP,
        }
        if role == "dependent" and guardian_id:
            user_data["guardianId"] = guardian_id

        db.collection("users").document(user_id).set(user_data)
        return jsonify({"message": "User added successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


# 소켓 연결
socketio = SocketIO(app, async_mode="eventlet")


@socketio.on("connect")
def connect(data):
    user_id = data.get("userId")  # 클라이언트에서 전달된 userId 사용
    if not user_id:
        return  # userId가 없으면 종료

    # Firebase에서 역할 가져오기
    user_doc = db.collection("users").document(user_id).get()
    if not user_doc.exists():
        return  # 사용자가 존재하지 않으면 종료

    user_role = user_doc.to_dict().get("role")
    join_room(user_id)

    if user_role == "guardian":
        socketio.emit("message", {"message": "Guardian connected"}, room=user_id)
    elif user_role == "dependent":
        socketio.emit("message", {"message": "Dependent connected"}, room=user_id)


# 보호자의 위치 업데이트
@socketio.on("location_update")
def location_update(data):
    user_id = data.get("userId")
    if not user_id:
        return

    user_doc = db.collection("users").document(user_id).get()
    if not user_doc.exists:
        return

    user_role = user_doc.to_dict().get("role")
    if user_role == "dependent":
        guardian_id = user_doc.to_dict().get("guardianId")
        if guardian_id:
            socketio.emit("location_update", data, room=guardian_id)


@socketio.on("location_request")
# @login_required
def location_request():
    # if current_user.role == "caregiver":
    # room = current_user.get_id()
    room = "alice"
    socketio.emit("location_request", room=room)


@socketio.on("disconnect")
def disconnect():
    room = "alice"
    leave_room(room)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
