import 'package:flutter/material.dart';
import '/pages/test.dart';
import '/pages/diary.dart';
import '/pages/location.dart';
import '/pages/taxi.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GRAD_Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: null, // AppBar 제거
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
          children: [
            SizedBox(height: 25), // 시간~배터리 부분 비워두기 (여기 원래 차는지 모르겠음)
            Container(
              color: Colors.blue, // 아이콘 박스의 background color
              padding: EdgeInsets.all(10), // 아이콘과 박스 사이 간격
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(Icons.home, size: 40, color: Colors.white),
                  Icon(Icons.person, size: 40, color: Colors.white),
                ],
              ),
            ),
            SizedBox(height: 30), // 상단 바 - 정보 사이 여백
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0), // 좌우 여백
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 이름과 나이 텍스트
                  Text(
                    '  이름 :  받아오기',
                    style: TextStyle(
                        fontSize: 27, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  Text(
                    '  나이 :  받아오기',
                    style: TextStyle(
                        fontSize: 27, fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                  SizedBox(height: 40),
                  _buildButtonGrid(context), // 버튼 Grid
                  SizedBox(height: 40),
                  _buildFooter(), // 하단 정보
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 페이지 이동 버튼
  Widget _buildButtonGrid(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMainButton(context, '점수 확인', Icons.arrow_right, TestPage()),
            SizedBox(width: 10), // 버튼 간격 조정
            _buildMainButton(context, '일기 쓰기', Icons.arrow_right, DiaryPage()),
          ],
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildMainButton(context, '위치 공유', Icons.arrow_right, LocationPage()),
            SizedBox(width: 10), // 버튼 간격 조정
            _buildMainButton(context, '이동 수단', Icons.arrow_right, TaxiPage()),
          ],
        ),
      ],
    );
  }

  // 버튼 정보
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.max, // 버튼 내 요소의 사이즈가 버튼 크기에 맞도록 확장
        children: [
          Flexible( //
            child: Text(
              label,
              style: TextStyle(
                fontSize: 27,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.visible, // 줄바꿈 on
            ),
          ),
          Icon(
            icon,
            size: 60,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

  // 하단 정보 부분
  Widget _buildFooter() {
    return Center( // 하단 글씨를 가운데 정렬
      child: Column(
        children: [
          Text(
            'COPYRIGHT 2024 BY 달리는 대방어',
            style: TextStyle(fontSize: 15, color: Colors.grey),
            textAlign: TextAlign.center, // 텍스트 중앙 정렬
          ),
        ],
      ),
    );
  }
}
