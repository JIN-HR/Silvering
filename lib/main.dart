import 'package:flutter/material.dart';
import 'pages/home.dart'; // 실제 홈 페이지로 사용될 페이지
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'login.dart';

//firebase login
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async { // main 함수 비동기로 변경
  WidgetsFlutterBinding.ensureInitialized(); // Flutter 초기화
  await Firebase.initializeApp( // Firebase 초기화
    options: DefaultFirebaseOptions.currentPlatform,
  );
  //TODO: 앱 실행 시 강제 로그아웃 - test용 (로그인 유지 시 이 줄 제거하기)
  await FirebaseAuth.instance.signOut();
  runApp(MyApp()); // MyApp 실행
}


//login 추가 전 main.dart
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '달리는 대방어',
      theme: ThemeData(
        fontFamily: 'GmarketSansTTF',
      ),
      home: AuthChecker(), // 초기 화면을 InitialPage로 설정
    );
  }
}

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 현재 로그인된 사용자 가져오기
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // 로그인 상태라면 home.dart로 이동
      return HomeApp();
    } else {
      // 로그아웃 상태라면 login.dart로 이동
      return LoginApp();
    }
  }
}

class InitialPage extends StatelessWidget { // 초기 화면 클래스
  @override
  Widget build(BuildContext context) {
    return Scaffold(

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
                  SizedBox(height: 40),
                  _buildButtonGrid(context), // _buildButtonGrid 메서드 호출
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

  // 페이지 이동 버튼 그리드
  Widget _buildButtonGrid(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMainButton(context, 'test: 홈', Icons.arrow_right, MyHomePage()), // home.dart의 MyHomePage로 이동
          SizedBox(height: 20),
        ],
      ),
    );
  }

  // 버튼 정보
  Widget _buildMainButton(BuildContext context, String label, IconData icon, Widget nextPage) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Color(0xFFFA8072),
        fixedSize: Size(360, 100),
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
        ],
      ),
    );
  }
}
