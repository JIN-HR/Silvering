import 'package:flutter/material.dart';
import 'dependentHome.dart';
import '../userinfo.dart';
import 'gamePage/languageGame.dart';
import 'gamePage/mathGame.dart';
import 'gamePage/memoryGame.dart';
import 'gamePage/patternGame.dart';

// ⇒ 단어 완성(언어) / 카드 페어 맞추기 (기억력) / 산수 (주의력) / 도형 패턴 맞추기 (추론)

class GamePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, ' '),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 50),
            Text(
              '어떤 기능을 연습하고 싶나요?',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2, // 2*2 grid
                crossAxisSpacing: 16, // 열 간격
                mainAxisSpacing: 16, // 행 간격
                childAspectRatio: 1.7, // 버튼의 가로:세로 비율
                children: [
                  _buildGameButton(context, '언어', Colors.orange, LanguageGamePage()),
                  _buildGameButton(context, '기억력', Colors.green, MemoryGamePage()),
                  _buildGameButton(context, '주의력', Colors.blue, MathGamePage()),
                  _buildGameButton(context, '추론', Colors.purple, PatternGamePage()),
                ],
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context, String title) {
    return AppBar(
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InfoPage(userRole: 'dependent'),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildGameButton(BuildContext context, String title, Color color, Widget page) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => page),
        );
      },
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            fontSize: 22,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'COPYRIGHT 2024 BY 달리는 대방어',
            style: TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}