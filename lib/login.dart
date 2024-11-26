import 'package:cyber_project/roleSelect.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:cyber_project/firebase_options.dart';

import 'package:flutter/material.dart';
import 'pages/dependantPages/dependentHome.dart';
import 'pages/guardianPages/guardianHome.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform); // Firebase 초기화
  runApp(LoginApp());
}

class LoginApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '달리는 대방어',
      theme: ThemeData(
        fontFamily: 'GmarketSansTTF',
      ),
      home: LoginPage(), // 초기 화면을 LoginPage로 설정
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        margin: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _header(context),
            _inputField(context),
            _signup(context),
          ],
        ),
      ),
    );
  }

  _header(context) {
    return const Column(
      children: [
        Text(
          "로그인",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  _inputField(context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _idController,
          decoration: InputDecoration(
            hintText: "아이디",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Color(0xFFFA8072).withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.person),
          ),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            hintText: "비밀번호",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
            fillColor: Color(0xFFFA8072).withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.lock),
          ),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            String id = _idController.text.trim();
            String password = _passwordController.text.trim();

            if (id.isEmpty || password.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('아이디와 비밀번호를 입력하세요.')),
              );
              return;
            }

            try {
              // Firestore에서 ID로 사용자 검색
              final querySnapshot = await FirebaseFirestore.instance
                  .collection('users')
                  .where('id', isEqualTo: id)
                  .get();

              if (querySnapshot.docs.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('아이디가 존재하지 않습니다.')),
                );
                return;
              }

              final userDoc = querySnapshot.docs.first;
              final storedPassword = userDoc['password'];
              final role = userDoc['role'];

              if (storedPassword != password) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('비밀번호가 일치하지 않습니다.')),
                );
                return;
              }

              // 역할에 따라 대시보드로 이동
              if (role == 'guardian') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Guardianhome()),
                );
              } else if (role == 'dependent') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => Dependenthome()),
                );
              } else {
                throw Exception('유효하지 않은 역할입니다.');
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('로그인 실패: $e')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            shape: const StadiumBorder(),
            padding: const EdgeInsets.symmetric(vertical: 16),
            backgroundColor: Color(0xFFFA8072),
          ),
          child: const Text(
            "로그인",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  _signup(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "계정이 없나요? ",
          style: TextStyle(fontSize: 20),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    RoleSelectionPage(guardianId: null), // guardianId를 null로 전달
              ),
            );
          },
          child: const Text(
            "회원가입하기",
            style: TextStyle(fontSize: 20, color: Color(0xFFFA8072)),
          ),
        ),
      ],
    );
  }
}
