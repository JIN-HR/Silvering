import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'roleSelect.dart'; // RoleSelectionPage 사용
import '../auth_service.dart'; // 경로: lib/auth_service.dart

class SignupPage extends StatefulWidget {
  @override
  _SignupPageState createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();
  final AuthService _authService = AuthService();

  String? _verificationId;
  bool _isCodeSent = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            height: MediaQuery.of(context).size.height - 50,
            width: double.infinity,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                // 헤더
                Column(
                  children: <Widget>[
                    const SizedBox(height: 60.0),
                    const Text(
                      "회원가입",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "계정을 생성하세요",
                      style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                    ),
                  ],
                ),
                // 전화번호 입력 및 인증 필드
                Column(
                  children: <Widget>[
                    // 전화번호 입력 필드
                    TextField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        hintText: "전화번호",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(18),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Color(0xFF5586E3).withOpacity(0.1),
                        filled: true,
                        prefixIcon: const Icon(Icons.phone),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // SMS 인증 코드 입력 필드 (코드가 전송된 경우에만 표시)
                    if (_isCodeSent)
                      TextField(
                        controller: _smsCodeController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: "SMS 인증 코드",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(18),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Color(0xFF5586E3).withOpacity(0.1),
                          filled: true,
                          prefixIcon: const Icon(Icons.lock),
                        ),
                      ),
                  ],
                ),
                // 버튼 섹션
                Container(
                  padding: const EdgeInsets.only(top: 3, left: 3),
                  child: ElevatedButton(
                    onPressed: _isCodeSent ? _verifySmsCode : _sendSmsCode,
                    child: Text(
                      _isCodeSent ? "SMS 코드 인증" : "SMS 코드 보내기",
                      style: const TextStyle(fontSize: 20),
                    ),
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: const Color(0xFF5586E3),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Text("이미 계정이 있나요?"),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        "로그인",
                        style: TextStyle(color: Color(0xFF5586E3)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // SMS 코드 전송
  void _sendSmsCode() async {
    String rawPhoneNumber = _phoneController.text.trim();

    // "010"으로 시작하는 경우만 처리
    if (rawPhoneNumber.startsWith('0')) {
      rawPhoneNumber = rawPhoneNumber.substring(1); // "010"의 "0" 제거
    }

    // E.164 형식으로 변환
    String formattedPhoneNumber = '+82$rawPhoneNumber';

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        onCodeSent: (verificationId, resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isCodeSent = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('SMS 코드가 전송되었습니다: $formattedPhoneNumber'),
          ));
        },
        onTimeout: (verificationId) {
          setState(() {
            _verificationId = verificationId;
            _isCodeSent = false;
          });
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('SMS 전송 중 오류 발생: $e'),
      ));
    }
  }


  // SMS 코드 인증 및 회원가입 처리
  void _verifySmsCode() async {
    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Verification ID를 찾을 수 없습니다. 다시 시도하세요.'),
      ));
      return;
    }

    try {
      // 인증 코드 확인 및 로그인
      await _authService.signInWithCode(
        _verificationId!,
        _smsCodeController.text.trim(),
        'guardian', // 기본 역할 설정
      );

      // 회원가입 성공 후 역할 선택 페이지로 이동
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => RoleSelectionPage(
            userId: FirebaseAuth.instance.currentUser!.uid,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('회원가입 중 오류 발생: $e'),
      ));
    }
  }


}
