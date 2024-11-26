// 카드 짝 맞추기 (기억력)

import 'package:flutter/material.dart';
import 'gameResult.dart';
import '../dependentHome.dart';
import '../../userinfo.dart';

class MemoryGamePage extends StatefulWidget {
  @override
  _MemoryGamePageState createState() => _MemoryGamePageState();
}

class _MemoryGamePageState extends State<MemoryGamePage> {
  final List<Map<String, String>> _cards = [
    {'id': '1', 'value': '✿'},
    {'id': '2', 'value': '★'},
    {'id': '3', 'value': '♥'},
    {'id': '4', 'value': '♠'},
    {'id': '5', 'value': '♣'},
    {'id': '6', 'value': '◆'},
    {'id': '7', 'value': '✿'},
    {'id': '8', 'value': '★'},
    {'id': '9', 'value': '♥'},
    {'id': '10', 'value': '♠'},
    {'id': '11', 'value': '♣'},
    {'id': '12', 'value': '◆'},
  ];
  List<Map<String, String>> _shuffledCards = [];
  List<int> _selectedIndices = [];
  bool _showAllCards = true; // 모든 카드를 보여줄지 여부
  int _score = 0;

  @override
  void initState() {
    super.initState();
    _shuffledCards = List.from(_cards)..shuffle();
    _startPreview(); // 카드 앞면 보여줌
  }

  void _startPreview() async {
    await Future.delayed(Duration(seconds: 10)); // 3초 대기
    setState(() {
      _showAllCards = false;
    });
  }

  void _selectCard(int index) {
    if (_selectedIndices.contains(index) || _selectedIndices.length >= 2 || _showAllCards) return;

    setState(() {
      _selectedIndices.add(index);
    });

    if (_selectedIndices.length == 2) {
      final firstCard = _shuffledCards[_selectedIndices[0]];
      final secondCard = _shuffledCards[_selectedIndices[1]];

      if (firstCard['value'] == secondCard['value']) {
        _score = 100;

        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _shuffledCards[_selectedIndices[0]]['value'] = '';
            _shuffledCards[_selectedIndices[1]]['value'] = '';
            _selectedIndices.clear();
          });

          if (_shuffledCards.every((card) => card['value'] == '')) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GameResultPage(score: _score, total: 100), // 총 점수 전달
              ),
            );
          }
        });
      } else {
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _selectedIndices.clear();
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
          children: [
            SizedBox(height:20),
            Text(
              '짝이 맞는 도형을 \n 연속해서 선택하세요!',
              style: TextStyle(fontSize: 24, color : Colors.grey[700], fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: _shuffledCards.length,
                itemBuilder: (context, index) {
                  final card = _shuffledCards[index];
                  final isSelected = _selectedIndices.contains(index);
                  final showCard = _showAllCards || isSelected || card['value'] == '';

                  return GestureDetector(
                    onTap: () => _selectCard(index),
                    child: Container(
                      decoration: BoxDecoration(
                        color: showCard ? Color(0xFFFA8072) : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          showCard ? card['value']! : '',
                          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
