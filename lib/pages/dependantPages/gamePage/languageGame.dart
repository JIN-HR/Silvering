import 'package:flutter/material.dart';
import 'gameResult.dart';
import '../dependentHome.dart';
import '../../userinfo.dart';

class LanguageGamePage extends StatefulWidget {
  @override
  _LanguageGamePageState createState() => _LanguageGamePageState();
}

class _LanguageGamePageState extends State<LanguageGamePage> {
  final List<Map<String, dynamic>> _questions = [
    {'question': '"다음다음 해"를 의미하는 단어는?', 'options': ['이듬해', '작년', '내후년'], 'answer': '내후년'},
    {'question': '"물건을 넣어 손에 들거나 어깨에 메고 다닐 수 있게 만든 용구"를 뜻하는 단어는?', 'options': ['가방', '사물함', '지갑'], 'answer': '가방'},
    {'question': '"즐겁다"와 비슷한 단어는?', 'options': ['섭섭하다', '기쁘다', '참다'], 'answer': '기쁘다'},
    {'question': '"기억하다"의 반대말은?', 'options': ['잊어버리다', '생각하다', '외우다'], 'answer': '잊어버리다'},
    {'question': '"백년가약"의 의미는?', 'options': ['언제나 깍듯이 대해야 하는\n어려운 손님', '오랫동안 기다려도\n바라는 것이 이루어질 수 없음', '부부가 되어 평생 같이 지낼 것을\n다짐하는 언약'], 'answer': '부부가 되어 평생 같이 지낼 것을 다짐하는 언약'},
  ];

  int _currentQuestionIndex = 0;
  int _score = 0;

  void _checkAnswer(String selectedOption) {
    if (selectedOption == _questions[_currentQuestionIndex]['answer']) {
      _score += 20;
    }

    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex += 1;
      });
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => GameResultPage(
            score: _score,
            total: 100,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = _questions[_currentQuestionIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFA8072),
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.white),
          iconSize: 40,
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => DependentDashboard()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            iconSize: 40,
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => InfoPage(userRole: 'dependent')),
                    (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '문제 ${_currentQuestionIndex + 1} / ${_questions.length}',
              style: TextStyle(fontSize: 24, color: Colors.grey[700], fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              question['question'],
              style: TextStyle(fontSize: 22, color: Colors.grey[700]),
              softWrap: true, // 줄바꿈 허용
              textAlign: TextAlign.left, // 텍스트 왼쪽 정렬
            ),

            SizedBox(height: 20),
            ...question['options'].map<Widget>((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => _checkAnswer(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFA8072),
                    fixedSize: Size(360, 100),
                    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // 둥근 모서리
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // 텍스트와 아이콘 정렬
                    children: [
                      Text(
                        option,
                        style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Icon(Icons.arrow_forward_ios, color: Colors.white), // 화살표 아이콘
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
