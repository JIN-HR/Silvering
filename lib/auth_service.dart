import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../pages/dependantPages/dependentHome.dart';
import '../pages/guardianPages/guardianHome.dart';


class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 기존 코드 생략...

  /// 역할 기반 리다이렉션
  Future<void> redirectToRolePage(BuildContext context) async {
    try {
      User? user = _firebaseAuth.currentUser;

      if (user != null) {
        // Firestore에서 사용자 역할 가져오기
        DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(user.uid).get();

        if (userDoc.exists) {
          String role = userDoc.get('role');

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
            throw Exception('알 수 없는 역할입니다.');
          }
        } else {
          throw Exception('사용자 정보가 Firestore에 없습니다.');
        }
      } else {
        throw Exception('로그인된 사용자가 없습니다.');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('페이지 이동 중 오류가 발생했습니다: $e')),
      );
    }
  }
}
