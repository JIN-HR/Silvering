import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Firestore 사용 시 필요

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore 객체 생성

  // SMS 인증 처리
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String verificationId) onTimeout,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) async {
        // 자동 인증 처리 로직
        await _signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        throw e.message ?? 'Verification failed';
      },
      codeSent: onCodeSent,
      codeAutoRetrievalTimeout: onTimeout,
    );
  }

  // 인증 코드 입력 후 사용자 로그인 처리
  Future<void> signInWithCode(String verificationId, String smsCode) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    await _signInWithCredential(credential);
  }

  // 인증 완료 후 사용자 정보 데이터베이스에 저장
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Firestore에 사용자 정보 저장 (필요 시 Realtime Database로 변경 가능)
        await _firestore.collection('users').doc(user.uid).set({
          'phoneNumber': user.phoneNumber,
          'uid': user.uid,
        });
      }
    } catch (e) {
      throw 'Sign-in failed: $e';
    }
  }
}
