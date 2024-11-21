//roleSelect.dart

import 'package:flutter/material.dart';

class RoleSelectionPage extends StatefulWidget {
  final String userId;

  RoleSelectionPage({required this.userId});

  @override
  _RoleSelectionPageState createState() => _RoleSelectionPageState();
}

class _RoleSelectionPageState extends State<RoleSelectionPage> {
  String? selectedRole; // 선택된 역할 (guardian 또는 dependent)
  String? errorMessage; // 에러 메시지

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("역할을 선택하세요")),
        body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "이 기기는 누가 사용하나요?",
                    style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  ElevatedButton(
                    onPressed: () async {
                      setState(() {
                        selectedRole = 'guardian';
                        errorMessage = null; // 에러 메시지 초기화
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedRole == 'guardian'
                          ? Color(0xFF5586E3)
                          : Colors.grey,
                      fixedSize: Size(360, 100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "보호자",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedRole = 'dependent';
                        errorMessage = null; // 에러 메시지 초기화
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedRole == 'dependent'
                          ? Color(0xFF5586E3)
                          : Colors.grey,
                      fixedSize: Size(360, 100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      "피보호자",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 20.0),
                  if (errorMessage != null)
                    Text(
                      errorMessage!,
                      style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  SizedBox(
                    height: 20.0,
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (selectedRole == null) {
                        setState(() {
                          errorMessage = "보호자 또는 피보호자를 선택하세요.";
                        });
                      } else {
                        // 역할 저장 로직 추가 (예: Firestore)
                        // FirebaseFirestore.instance
                        //     .collection('users')
                        //     .doc(widget.userId)
                        //     .set({'role': selectedRole}, SetOptions(merge: true));

                        // 보호자 페이지로 이동
                        if (selectedRole == 'guardian') {
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => GuardianDashboard()),
                          // );
                        } else {
                          //Navigator.push(
                          //   context,
                          //   MaterialPageRoute(builder: (context) => DependentDashboard()),
                          // );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      fixedSize: Size(360, 100),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      backgroundColor: Colors.green,
                    ),
                    child: Text(
                      "시작하기",
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            )));
  }
}
