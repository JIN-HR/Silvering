import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DependentSignupPage extends StatefulWidget {
  final String guardianId; // 보호자의 UID

  DependentSignupPage({required this.guardianId}); // guardianId를 생성자로 받음

  @override
  _DependentSignupPageState createState() => _DependentSignupPageState();
}

class _DependentSignupPageState extends State<DependentSignupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _smsCodeController = TextEditingController();

  String? _verificationId;
  bool _isCodeSent = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("피보호자 회원가입")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: "전화번호"),
            ),
            if (_isCodeSent)
              TextField(
                controller: _smsCodeController,
                decoration: InputDecoration(labelText: "SMS 인증 코드"),
              ),
            if (_isCodeSent)
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "피보호자 이름"),
              ),
            if (_isCodeSent)
              TextField(
                controller: _idController,
                decoration: InputDecoration(labelText: "ID"),
              ),
            if (_isCodeSent)
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "비밀번호"),
              ),
            ElevatedButton(
              onPressed: _isCodeSent ? _verifySmsCode : _sendSmsCode,
              child: Text(_isCodeSent ? "회원가입 완료" : "SMS 코드 보내기"),
            ),
          ],
        ),
      ),
    );
  }

  // SMS 코드 전송
  void _sendSmsCode() async {
    String rawPhoneNumber = _phoneController.text.trim();

    // "010"으로 시작하는 경우 "0"을 제거하고 E.164 형식으로 변환
    if (rawPhoneNumber.startsWith('0')) {
      rawPhoneNumber = rawPhoneNumber.substring(1); // "010"의 "0" 제거
    }
    String formattedPhoneNumber = '+82$rawPhoneNumber';

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // 자동으로 인증 성공 시 호출
          await FirebaseAuth.instance.signInWithCredential(credential);
          _onVerificationSuccess();
        },
        verificationFailed: (FirebaseAuthException e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("SMS 전송 실패: ${e.message}")),
          );
        },
        codeSent: (verificationId, resendToken) {
          setState(() {
            _verificationId = verificationId;
            _isCodeSent = true;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("SMS 코드가 전송되었습니다: $formattedPhoneNumber")),
          );
        },
        codeAutoRetrievalTimeout: (verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SMS 전송 실패: $e")),
      );
    }
  }

  // SMS 코드 인증 및 회원가입 처리
  void _verifySmsCode() async {
    if (_verificationId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Verification ID를 찾을 수 없습니다. 다시 시도하세요.")),
      );
      return;
    }

    final smsCode = _smsCodeController.text.trim();
    final name = _nameController.text.trim();
    final id = _idController.text.trim();
    final password = _passwordController.text.trim();

    if (smsCode.isEmpty || name.isEmpty || id.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("모든 필드를 입력하세요.")),
      );
      return;
    }

    try {
      // SMS 인증 코드 확인
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: smsCode,
      );

      final userCredential =
      await FirebaseAuth.instance.signInWithCredential(credential);

      // Firestore에 피보호자 정보 저장 및 관계 설정
      try {
        String dependentUid = FirebaseAuth.instance.currentUser!.uid;

        await FirebaseFirestore.instance.collection('users').doc(dependentUid).set({
          'name': name,
          'id': id,
          'password': password,
          'phoneNumber': _phoneController.text.trim(),
          'role': 'dependent',
          'guardianId': widget.guardianId,
        });

        // 피보호자의 guardianId 업데이트
        await FirebaseFirestore.instance.collection('users').doc(dependentUid).update({
          'guardianId': widget.guardianId,
        });

        // 보호자의 dependentIds 배열에 피보호자 UID 추가
        await FirebaseFirestore.instance.collection('users').doc(widget.guardianId).update({
          'dependentIds': FieldValue.arrayUnion([dependentUid]),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("회원가입이 완료되었습니다!")),
        );

        Navigator.popUntil(context, (route) => route.isFirst); // 로그인 화면으로 돌아감
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("회원가입 실패: $e")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원가입 실패: $e")),
      );
    }
  }


  // 자동 인증 성공 처리
  void _onVerificationSuccess() {
    setState(() {
      _isCodeSent = true;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("전화번호 인증이 완료되었습니다.")),
    );
  }
}
