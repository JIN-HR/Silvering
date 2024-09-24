import 'package:flutter/material.dart';
import 'pages/diary.dart';
import 'pages/test.dart';
import 'pages/location.dart';
import 'pages/taxi.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MAIN',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MainPage(),
    );
  }
}

class MainPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // AppBar 제거
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 40), // 아이콘 위 패딩 추가
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.home, size: 40,  color: Color(0xFF4A4A4A)),
                  Icon(Icons.person, size: 40,  color: Color(0xFF4A4A4A)),
                ],
              ),
              SizedBox(height: 30), // 이름 + 나이
              Text(
                '  이름 :  받아오기',
                style: TextStyle(
                    fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
              ),
              Text(
                '  나이 :  받아오기',
                style: TextStyle(
                    fontSize: 25, fontWeight: FontWeight.bold, color: Color(0xFF4A4A4A)),
              ),
              SizedBox(height: 40),
              _buildButtonGrid(context), // 버튼 -> 그리드
              SizedBox(height: 40),
              _buildFooter(), // 정보
            ],
          ),
        ),
      ),
    );
  }

  // 페이지 이동 버튼 그리드
  Widget _buildButtonGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMainButton(context, '접수 확인', Icons.arrow_right, TestPage()),
            SizedBox(width: 10), // 버튼 간격
            _buildMainButton(context, '일기 쓰기', Icons.arrow_right, DiaryPage()),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMainButton(context, '위치 공유', Icons.arrow_right, LocationPage()),
            SizedBox(width: 10), // 버튼 간격
            _buildMainButton(context, '이동 수단', Icons.arrow_right, TaxiPage()),
          ],
        ),
      ],
    );
  }

  // 버튼 빌드 함수
  Widget _buildMainButton(BuildContext context, String label, IconData icon, Widget nextPage) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        fixedSize: Size(160, 110), // 고정 크기 설정
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => nextPage),
        );
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween, // 아이템들을 버튼 내에서 공간을 효율적으로 차지하도록 조정
        mainAxisSize: MainAxisSize.max, // 버튼 내 요소의 사이즈가 버튼 크기에 맞도록 확장
        children: [
          Flexible( // 텍스트가 버튼 크기를 넘지 않도록 조정
            child: Text(
              label,
              style: TextStyle(
                fontSize: 25, // 글자 크기 약간 조정
                color: Colors.white, // 글자 색상을 흰색으로 설정
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 10),
          Icon(
            icon,
            size: 50,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  // 하단 정보
  Widget _buildFooter() {
    return Center( // 하단 글씨를 가운데 정렬
      child: Column(
        children: [
          Text(
            'COPYRIGHT 2024 BY 달리는 대방어',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
