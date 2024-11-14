from flask import Flask, request, jsonify
from flask_cors import CORS
from captioning import generate_korean_caption
from flask_socketio import SocketIO, join_room, leave_room
from flask_login import login_manager, login_user, login_required, current_user
from test_eval import eval_response

# CORS 설정
app = Flask(__name__)
CORS(app, resources={r"/generate_caption": {"origins": "*"}}) # origin allow
CORS(app, resources={r"/evaluate": {"origins": "*"}}) # origin allow


# 사용자 예제
users = {"alice": {"role": "protector"}, "alice": {"role": "client"}}

class User:
    def __init__(self, username, role):
        self.username = username
        self.role = role

    def is_authenticated(self):
        return True

    def get_id(self):
        return self.username

### 기능 A
@app.route('/evaluate', methods=['POST'])
def evaluate():
    # 클라이언트로부터 JSON 데이터 받기
    data = request.get_json()  # 안전하게 JSON 데이터를 파싱합니다.

    if not data or 'text' not in data or 'question_number' not in data:
        return jsonify({"error": "Invalid data provided"}), 400

    user_text = data['text']
    question_number = data['question_number']  # question_number 값을 받음

    # 평가 함수 호출
    evaluation = eval_response(user_text, question_number)

    # 응답 반환
    return jsonify({"evaluation": evaluation})

    # 평가 함수 호출 (예제로 eval_response_1을 사용)
    evaluation = eval_response(user_text, question_number)

    # 응답 반환
    return jsonify({"evaluation": evaluation})


# 기능 B
@app.route('/generate_caption', methods=['GET', 'POST'])
def generate_caption():
    if 'image' not in request.files:
        return jsonify({"error": "이미지가 선택되지 않았습니다."}), 400

    image = request.files['image']
    image_path = "./temp_image.jpg"
    image.save(image_path)

    # 날짜 데이터
    year = request.form.get('year')
    month = request.form.get('month')
    day = request.form.get('day')

    # 서버 전송 확인
    print(f"app.py - Year: {year}, Month: {month}, Day: {day}")

    # 캡션 생성
    caption, runtime = generate_korean_caption(image_path, year, month, day)
    print("app.py - ", caption)
    return jsonify({
        "caption": caption,
        "runtime": runtime
    })







# 소켓 연결
socketio = SocketIO(app, async_mode="eventlet")

@socketio.on("connect")
# @login_required
def connect():
    # room = current_user.get_id()
    room = "alice"
    join_room(room)

    # 피보호자와 보호자를 구분, 같은 room에 넣기
    # if current_user.role == "caregiver":
    #     socketio.emit("caregiver", {"message": "Caregiver Connected"}, to=room)
    # elif current_user.role == "patient":
    #     socketio.emit("patient", {"message": "Patient Connected"}, to=room)






# 보호자의 위치 업데이트
@socketio.on("location_update")
# @login_required
def location_update(data):
    role = "patient"
    room = "alice"
    if role == "patient":
        socketio.emit("location_update", data, room=room)


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

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
