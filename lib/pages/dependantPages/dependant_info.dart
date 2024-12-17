import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cyber_project/sharedPreferences_helper.dart'; // 헬퍼 클래스 import

class DependentInfoPage extends StatefulWidget {
  @override
  _DependantInfoPageState createState() => _DependantInfoPageState();
}

class _DependantInfoPageState extends State<DependentInfoPage> {
  String? userId;
  String? name;
  String? role;
  String? phoneNumber;
  List<Map<String, dynamic>> testResults = [];

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) {
      setState(() {
        userId = "로그인된 사용자가 없습니다.";
        name = "N/A";
        role = "N/A";
        phoneNumber = "N/A";
      });
      return;
    }

    try {
      // Firestore에서 사용자 정보 가져오기
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          userId = userDoc['id'];
          name = userDoc['name'];
          role = userDoc['role'];
          phoneNumber = currentUser.phoneNumber ?? "전화번호 정보 없음";
        });

        // 테스트 결과 가져오기
        final testResultsSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('test_results')
            .get();

        setState(() {
          testResults = testResultsSnapshot.docs.map((doc) {
            return {
              'score': doc['score'],
              'categoryScores': doc['categoryScores'],
              'timestamp': (doc['timestamp'] as Timestamp).toDate().toString(),
            };
          }).toList();
        });
      } else {
        setState(() {
          userId = "사용자 정보를 찾을 수 없습니다.";
          name = "N/A";
          role = "N/A";
          phoneNumber = "N/A";
        });
      }
    } catch (e) {
      setState(() {
        userId = "오류 발생: $e";
        name = "N/A";
        role = "N/A";
        phoneNumber = "N/A";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("사용자 정보"),
        backgroundColor: Color(0xFFFA8072),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text(
              "현재 로그인된 사용자 정보",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            Text(
              "ID: $userId",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "이름: $name",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "역할: ${role == 'dependent' ? '피보호자' : '보호자'}",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              "전화번호: $phoneNumber",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Divider(),
            Text(
              "테스트 결과",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 10),
            if (testResults.isEmpty)
              Text("테스트 결과가 없습니다.", style: TextStyle(fontSize: 16)),
            ...testResults.map((result) {
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("점수: ${result['score']}"),
                      Text("카테고리별 점수: ${result['categoryScores']}"),
                      Text("날짜: ${result['timestamp']}"),
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
