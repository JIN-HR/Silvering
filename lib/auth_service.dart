import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 전화번호 인증 처리
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String verificationId, int? resendToken) onCodeSent,
    required Function(String verificationId) onTimeout,
  }) async {
    try {
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // 자동 인증 처리
          await _signInWithCredential(credential, role: 'guardian'); // 기본 역할을 설정 (필요 시 수정 가능)
        },
        verificationFailed: (FirebaseAuthException e) {
          throw FirebaseAuthException(
            code: e.code,
            message: e.message ?? 'Verification failed',
          );
        },
        codeSent: onCodeSent,
        codeAutoRetrievalTimeout: onTimeout,
      );
    } catch (e) {
      throw Exception('Failed to verify phone number: $e');
    }
  }

  /// 인증 코드 입력 후 로그인 처리
  Future<void> signInWithCode(
      String verificationId,
      String smsCode,
      String role, {
        String? guardianId,
      }) async {
    try {
      // 인증 자격 증명 생성
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // 인증 자격 증명을 사용해 로그인
      await _signInWithCredential(credential, role: role, guardianId: guardianId);
    } catch (e) {
      throw Exception('Failed to sign in with code: $e');
    }
  }

  /// 인증 완료 후 Firestore에 사용자 정보 저장
  Future<void> _signInWithCredential(
      PhoneAuthCredential credential, {
        required String role,
        String? guardianId,
      }) async {
    try {
      UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      User? user = userCredential.user;

      if (user != null) {
        // Firestore에 사용자 정보 저장
        Map<String, dynamic> userData = {
          'phoneNumber': user.phoneNumber,
          'uid': user.uid,
          'role': role, // 사용자 역할 (guardian 또는 dependent)
          'createdAt': FieldValue.serverTimestamp(),
        };

        // 피보호자인 경우 보호자 ID 추가
        if (role == 'dependent' && guardianId != null) {
          userData['guardianId'] = guardianId;
        }

        // Firestore에 저장 (병합 설정)
        await _firestore.collection('users').doc(user.uid).set(userData, SetOptions(merge: true));
      }
    } catch (e) {
      throw Exception('Failed to sign in and save user data: $e');
    }
  }

  /// Firestore에서 특정 사용자 정보 가져오기
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();
      if (userDoc.exists) {
        return userDoc.data() as Map<String, dynamic>;
      }
      return null; // 사용자 정보가 없을 경우
    } catch (e) {
      throw Exception('Failed to fetch user data: $e');
    }
  }

  /// Firestore에서 사용자 역할 업데이트
  Future<void> updateUserRole(String uid, String role, {String? guardianId}) async {
    try {
      Map<String, dynamic> updatedData = {'role': role};

      // 피보호자인 경우 guardianId 추가
      if (role == 'dependent' && guardianId != null) {
        updatedData['guardianId'] = guardianId;
      }

      // Firestore에 업데이트
      await _firestore.collection('users').doc(uid).update(updatedData);
    } catch (e) {
      throw Exception('Failed to update user role: $e');
    }
  }
}
