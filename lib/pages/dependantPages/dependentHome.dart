// dependentHome.dart : 피보호자 홈

import 'package:flutter/material.dart';
import 'test.dart'; // 인지 능력 검사 페이지
import 'diary.dart'; // 일기 쓰기 페이지

import '../userinfo.dart';
import 'game.dart'; //게임 페이지
//import 'chat.dart'; // 전문가 상담 페이지

class Dependenthome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '달리는 대방어',
      theme: ThemeData(
        fontFamily: 'GmarketSansTTF',
      ),
      home: DependentDashboard(),
    );
  }
}

class DependentDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFA8072),
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.white),
          iconSize: 40, // 아이콘 크기 설정
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            iconSize: 40, // 아이콘 크기 설정
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => InfoPage(userRole: 'dependent')),
                    (Route<dynamic> route) => false,
              );              // 사용자 정보 페이지로 이동
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 30),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '  이름 :  대방어',
                    style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700]),
                  ),
                  Text(
                    '  나이 :  76세',
                    style: TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w400,
                        color: Colors.grey[700]),
                  ),
                  SizedBox(height: 40),
                  _buildButtonGrid(context),
                  SizedBox(height: 40),
                  _buildFooter(),
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
    return Center(
      child: Column(
        mainAxisAlignment:
        MainAxisAlignment.center, // Centers the buttons vertically
        children: [
          _buildMainButton(context, '인지 검사', Icons.arrow_right, TestPage()),
          SizedBox(height: 20), // Add space between buttons
          _buildMainButton(context, '두뇌 게임', Icons.arrow_right, GamePage()),
          SizedBox(height: 20),
          _buildMainButton(context, '일기 쓰기', Icons.arrow_right, DiaryPage()),
          SizedBox(height: 20),
          //_buildMainButton(context, '게임', Icons.arrow_right, GamePage()),
          //SizedBox(height: 20),
          //_buildMainButton(context, '게시판', Icons.arrow_right, TaxiPage()),
        ],
      ),
    );
  }

  // 버튼 정보
  Widget _buildMainButton(
      BuildContext context, String label, IconData icon, Widget nextPage) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFA8072),
        fixedSize: Size(360, 80),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
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
        mainAxisSize: MainAxisSize.max,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
              softWrap: true,
              overflow: TextOverflow.visible,
            ),
          ),
          SizedBox(width: 20),
          Icon(
            icon,
            size: 50,
            color: Colors.white,
          ),
        ],
      ),
    );
  }

}

// 하단 정보 부분
Widget _buildFooter() {
  return Center(
    child: Column(
      children: [
        Text(
          'COPYRIGHT 2024 BY 달리는 대방어',
          style: TextStyle(fontSize: 12, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
        SizedBox(height:20),
      ],
    ),
  );
}