//set_location.dart 피보호자 안전 구역 설정

import 'package:flutter/material.dart';
import '../userinfo.dart';
//import 'package:webview_flutter/webview_flutter.dart';
//import 'dart:convert';
import 'package:kpostal/kpostal.dart';

import 'guardianHome.dart';

class SafeZonePage extends StatefulWidget {
  @override
  State<SafeZonePage> createState() => _SafeZonePageState();
}

class _SafeZonePageState extends State<SafeZonePage> {
  String roadAddress = '-';
  String latitude = '-';
  String longitude = '-';

  List<Map<String, String>> addressList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFFFA8072),
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.white),
          iconSize: 40, // 아이콘 크기 설정
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => GuardianDashboard()),
                  (Route<dynamic> route) => false,
            ); // home.dart로
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            iconSize: 40, // 아이콘 크기 설정
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InfoPage(userRole: 'dependent'),
                ),
              );// 사용자 정보 페이지로 이동
            },
          ),
        ],
      ),
      body: Container(
        alignment: Alignment.center,
        child: Column(
          //mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(40),
              child: Text(
                "피보호자가 안전 구역에서 \n 100m 이상 벗어나면 \n 알람을 해드립니다.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            TextButton(
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => KpostalView(
                      useLocalServer: true,
                      localPort: 1024,
                      callback: (Kpostal result) {
                        setState(() {
                          roadAddress = result.address;
                          latitude = result.latitude.toString();
                          longitude = result.longitude.toString();
                        });
                        addressList.add({
                          'roadAddress': roadAddress,
                          'latitude': latitude,
                          'longitude': longitude,
                        });
                      },
                    ),
                  ),
                );
              },
              style: ButtonStyle(
                backgroundColor:
                WidgetStateProperty.all<Color>(Color(0xFFFA8072)),
                padding: WidgetStateProperty.all<EdgeInsets>(
                  EdgeInsets.symmetric(
                      vertical: 16.0, horizontal: 32.0), // 버튼 내부 여백
                ),
                minimumSize:
                WidgetStateProperty.all<Size>(Size(200, 60)), // 최소 크기 설정
                shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // 둥근 모서리 설정
                  ),
                ),
              ),
              child: const Text(
                '주소 검색',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                children: [
                  roadAddress == '-'
                      ? Text('안전 구역을 설정해보세요!',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20))
                      : Text('현재 안전 구역 : $roadAddress',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}