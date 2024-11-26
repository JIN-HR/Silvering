// 규칙 찾기 게임 페이지 (추론)

import 'package:flutter/material.dart';
import 'gameResult.dart';
import '../dependentHome.dart';
import '../../userinfo.dart';

class PatternGamePage extends StatefulWidget {
  @override
  _PatternGamePageState createState() => _PatternGamePageState();
}

class _PatternGamePageState extends State<PatternGamePage> {
  final List<Map<String, dynamic>> _questions = [
    {
      'question': '◯ ⬤ ◯ ⬚ ◯',
      'options': ['◯', '⬤', '⦿'],
      'answer': '⬤'
    },
    {
      'question': '◧ ◨ ◧ ⬚ ◧',
      'options': ['◨', '◑', '◧'],
      'answer': '◨'
    },
    {
      'question': '◀ ⬚ ▶ ▼ ◀ ▲',
      'options': ['▲', '▶', '▼'],
      'answer': '▲'
    },
    {
      'question': '🂡 🂢 🂣 ⬚ 🂥 🂦',
      'options': ['🂢', '🂣', '🂤'],
      'answer': '🂤'
    },
    {
      'question': '1-1-2-3-5-8-⬚',
      'options': ['11', '12', '13'],
      'answer': '13'
    },
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
                  builder: (context) => InfoPage(userRole: 'dependent'),
                ),
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
              '문제 ${_currentQuestionIndex + 1} / ${_questions.length} \n⬚ 에 들어갈 것은?',
              style: TextStyle(fontSize: 24, color: Colors.grey[700], fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              question['question'],
              style: TextStyle(fontSize: 35, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20),
            ...question['options'].map<Widget>((option) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () => _checkAnswer(option),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFFFA8072),
                    fixedSize: Size(360, 80),
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
                        style: TextStyle(fontSize: 30, color: Colors.white, fontWeight: FontWeight.bold),
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
