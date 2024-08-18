from flask import Flask, request, jsonify
from captioning import generate_korean_caption
from flask_cors import CORS

app = Flask(__name__)
CORS(app)

@app.route('/generate_caption', methods=['POST'])
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
    app.run(host='0.0.0.0', port=5000)  #실행
