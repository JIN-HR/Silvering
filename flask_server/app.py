from flask import Flask, request, jsonify
from flask_cors import CORS
from captioning import generate_korean_caption

# CORS 설정
app = Flask(__name__)
CORS(app, resources={r"/generate_caption": {"origins": "*"}}) # origin allow
# 초기 화면: 회원가입 폼을 보여줌
@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        # 회원가입 요청 처리 (DB 저장 등)
        username = request.form['username']
        password = request.form['password']

        # 여기서 회원가입 로직을 처리 (예: DB 저장)
        return jsonify({
            "message": f"회원가입이 완료되었습니다, {username}님. 로그인하세요.",
            "login_url": "/login"
        })

    # GET 요청일 때 회원가입 HTML 렌더링
    return render_template('index.html')  # templates/index.html 파일을 렌더링


# login
@app.route('/login', methods=['GET','POST'])
def login():
#     # 로그인 요청 처리 (예: DB 대조)
#     data = request.get_json()
#     username = data.get('username')
#     password = data.get('password')
#
#     # 여기서 로그인 검증 로직 처리 (DB 대조 등)
#     if username == "testuser" and password == "testpassword":  # 예시 검증 로직
#         return redirect(url_for('main'))  # 로그인 성공 시 메인 화면으로 이동
#     else:
#         return jsonify({
#             "message": "login failed"
#         })
    return render_template('login.html')

# 메인 화면 (기능 선택 창)
@app.route('/main')
def main():
    # 기능 A(level_test와 generate_caption으로 이동)
    return render_template('main.html')

# 기능 A
@app.route('/level_test')
def level_test():

    return render_template('level_test.html')

# 기능 B
@app.route('/generate_caption', methods=['GET', 'POST'])
def generate_caption():
    if 'image' not in request.files:
        return jsonify({"error": "이미지가 선택되지 않았습니다."}), 400

    image = request.files['image']
    image_path = "./temp_image.jpg"
    image.save(image_path)

    caption, runtime = generate_korean_caption(image_path)

    return jsonify({
        "caption": caption,
        "runtime": runtime
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
