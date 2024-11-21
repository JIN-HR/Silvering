import 'package:firebase_core/firebase_core.dart';
import 'package:cyber_project/firebase_options.dart';

import 'package:flutter/material.dart';
import 'roleSelect.dart';
import 'signup.dart';
import 'login.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform); // Firebase 초기화
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
      home: LoginPage(), // 초기 화면을 loginPage로 설정
    );
  }
}

class LoginPage extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  //const LoginPage({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          margin: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _header(context),
              _inputField(context),
              _forgotPassword(context),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }

  _header(context) {
    return const Column(
      children: [
        Text(
          "보호자 계정 로그인",
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
          decoration: InputDecoration(
              hintText: "아이디",
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(18),
                  borderSide: BorderSide.none),
              fillColor: Color(0xFFFA8072).withOpacity(0.1),
              filled: true,
              prefixIcon: const Icon(Icons.person)),
        ),
        const SizedBox(height: 10),
        TextField(
          decoration: InputDecoration(
            hintText: "비밀번호",
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
                borderSide: BorderSide.none),
            fillColor: Color(0xFFFA8072).withOpacity(0.1),
            filled: true,
            prefixIcon: const Icon(Icons.password),
          ),
          obscureText: true,
        ),
        // const SizedBox(height: 10,),
        // ElevatedButton(onPressed: () {}, child: child)

        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            // Firebase Authentication으로 로그인
            try {
              // UserCredential userCredential = await FirebaseAuth.instance
              //     .signInWithEmailAndPassword(
              //         email: _emailController.text.trim(),
              //         password: _passwordController.text.trim());
              // 로그인 성공 시 역할 선택 화면으로 이동
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RoleSelectionPage(
                        userId: 'alice')), //userCredential.user!.uid)),
              );
            } catch (e) {
              print("Login failed: $e");
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
        )
      ],
    );
  }

  _forgotPassword(context) {
    return TextButton(
      onPressed: () {},
      child: const Text(
        "비밀번호를 까먹었나요?",
        style: TextStyle(fontSize: 20, color: Color(0xFFFA8072)),
      ),
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => SignupPage()));
            },
            child: const Text(
              "회원가입",
              style: TextStyle(fontSize: 20, color: Color(0xFFFA8072)),
            ))
      ],
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
        ],
      ),
    );
  }
}
