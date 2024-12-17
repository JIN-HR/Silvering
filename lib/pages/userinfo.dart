import 'package:flutter/material.dart';
import 'dependantPages/dependentHome.dart';
import 'guardianPages/guardianHome.dart';

class InfoPage extends StatelessWidget {
  final String userRole; // 사용자 역할을 전달받음 ('guardian' 또는 'dependent')

  InfoPage({required this.userRole});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFA8072),
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.white),
          iconSize: 40, // 아이콘 크기 설정
          onPressed: () {
            // 역할에 따라 홈 페이지로 이동
            if (userRole == 'guardian') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => GuardianDashboard()),
              );
            } else if (userRole == 'dependent') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => DependentDashboard()),
              );
            }
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            iconSize: 40, // 아이콘 크기 설정
            onPressed: () {
              // InfoPage로 다시 이동 (동일 역할 유지)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => InfoPage(userRole: userRole)),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Text(
          '유저 정보 페이지',
          style: TextStyle(fontSize: 20),
        ),
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
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
