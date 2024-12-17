import 'package:flutter/material.dart';
import 'pages/dependantPages/dependant_signup.dart';
import 'pages/guardianPages/guardian_signup.dart';

class RoleSelectionPage extends StatelessWidget {
  final String? guardianId; // null이 될 수 있도록 수정

  RoleSelectionPage({this.guardianId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("회원가입")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "보호자를 등록하고 진행하시겠습니까?",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: () {
                  if (guardianId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("먼저 보호자를 등록해주세요.")),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DependentSignupPage(guardianId: guardianId!),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFA8072),
                  fixedSize: Size(250, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "예",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  if (guardianId != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DependentSignupPage(
                          guardianId: guardianId!, // 보호자 ID 전달
                        ),
                      ),
                    );
                  } else {
                    // guardianId가 없는 경우 경고 메시지 출력
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("먼저 보호자 등록을 완료하세요.")),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  fixedSize: Size(250, 60),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  "아니오",
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
