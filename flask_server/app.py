from flask import Flask, request, jsonify
from flask_cors import CORS
from captioning import generate_korean_caption

# CORS 설정
app = Flask(__name__)
CORS(app, resources={r"/generate_caption": {"origins": "*"}}) # origin allow
# 초기 화면: 회원가입 폼을 보여줌
@app.route('/', methods=['GET', 'POST'])
def signup():
    ##
    return render_template('index.html')  # templates/index.html 파일을 렌더링


# login
@app.route('/login', methods=['GET','POST'])
def login():
#
    return render_template('login.html')

# 기능 B
@app.route('/generate_caption', methods=['GET', 'POST'])
def generate_caption():
    if 'image' not in request.files:
        return jsonify({"error": "이미지가 선택되지 않았습니다."}), 400

    image = request.files['image']
    image_path = "./temp_image.jpg"
    image.save(image_path)

    # 날짜 데이터 받기
    year = request.form.get('year')
    month = request.form.get('month')
    day = request.form.get('day')

    # 서버에서 받은 데이터를 출력 (로그 용도)
    print(f"app.py - Year: {year}, Month: {month}, Day: {day}")

    # 캡션 생성 함수에 날짜 데이터 전달
    caption, runtime = generate_korean_caption(image_path, year, month, day)

    return jsonify({
        "caption": caption,
        "runtime": runtime
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
