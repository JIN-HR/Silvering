import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'test.dart';
import 'diary.dart';
import 'dependant_info.dart';
import 'game.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cyber_project/sharedPreferences_helper.dart'; // 헬퍼 클래스 import

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
  Future<Map<String, dynamic>> _getUserData() async {
    // SharedPreferences에서 id 가져오기
    final userId = await SharedPrefsHelper.getUserId();

    if (userId == null) {
      throw Exception('로그인 상태가 아닙니다. 다시 로그인해주세요.');
    }

    // Firestore에서 id로 사용자 데이터 검색
    final querySnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('id', isEqualTo: userId)
        .get();

    if (querySnapshot.docs.isEmpty) {
      throw Exception('사용자 데이터를 찾을 수 없습니다.');
    }

    return querySnapshot.docs.first.data();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('오류가 발생했습니다: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('데이터를 불러올 수 없습니다.'));
        }

        final userData = snapshot.data!;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Color(0xFFFA8072),
            leading: IconButton(
              icon: Icon(Icons.home, color: Colors.white),
              iconSize: 40,
              onPressed: () {},
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.person, color: Colors.white),
                iconSize: 40,
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DependentInfoPage()),
                  );
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
                        '  이름 :  ${userData['name'] ?? '알 수 없음'}',
                        style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey[700]),
                      ),
                      Text(
                        '  나이 :  ${userData['age'] ?? '알 수 없음'}',
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
      },
    );
  }


  Widget _buildButtonGrid(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildMainButton(context, '인지 검사', Icons.arrow_right, TestPage()),
          SizedBox(height: 20),
          _buildMainButton(context, '두뇌 게임', Icons.arrow_right, GamePage()),
          SizedBox(height: 20),
          _buildMainButton(context, '일기 쓰기', Icons.arrow_right, DiaryPage()),
          SizedBox(height: 20),
        ],
      ),
    );
  }

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
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 30,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
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


Widget _buildFooter() {
  return Center(
    child: Column(
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
