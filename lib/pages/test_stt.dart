// test.dart : 인지 능력 검사

import 'package:flutter/material.dart';
import 'home.dart';
import 'userinfo.dart';
import 'package:cyber_project/stt.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  final SpeechService _speechService = SpeechService();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  //STT 초기화 및 자동 시작
  Future<void> _initSpeech() async {
    await _speechService.initialize();
    //setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _speechService.onSpeechResult(result);
      _textController.text = _speechService.lastWords;
      print('Speech result received: ${result.recognizedWords}');
    });
  }

  Future<void> _startListening() async {
    await Future.delayed(Duration(seconds: 1));
    await _speechService.startListening(_onSpeechResult);
  }

  Future<void> _stopListening() async {
    await Future.delayed(Duration(seconds: 5));
    await _speechService.stopListening();
  }

  void _toggleListening() async {
    if (_speechService.isListening) {
      await _stopListening();
    } else {
      await _startListening();
    }
    setState(() {
      print('Listening state: ${_speechService.isListening}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5586E3),
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.white),
          iconSize: 40, // 아이콘 크기 설정
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => MyHomePage()),
                  (Route<dynamic> route) => false,
            ); // home.dart로
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            iconSize: 40, // 아이콘 크기 설정
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => InfoPage()),
                    (Route<dynamic> route) => false,
              ); // 사용자 정보 페이지로 이동
            },
          ),
        ],
      ),
      body: Center(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(12),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    minLines: 6,
                    maxLines: 10,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.shade300,
                    ),
                  ),
                ),
                IconButton(
                    onPressed: _toggleListening,
                    icon: Icon(
                      _speechService.isListening ? Icons.mic : Icons.mic_off,
                    ))
              ],
            ),
          ],
        ),
      ),
    );
  }
}
