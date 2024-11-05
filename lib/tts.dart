import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  static final TtsService _instance = TtsService._internal();
  final FlutterTts _tts = FlutterTts();

  factory TtsService() {
    return _instance;
  }

  TtsService._internal() {
    _initializeTts();
  }

  void _initializeTts() {
    _tts.setLanguage("ko-KR");
    _tts.setSpeechRate(0.5);
    _tts.setVolume(0.6);
    _tts.setPitch(1);
  }

  Future<void> speak(String text) async {
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}


//// 다른 페이지 사용 예시
// import 'package:flutter/material.dart';
// import 'tts.dart';
//
// class TextToSpeechPage extends StatelessWidget {
//   final TextEditingController ttsController = TextEditingController();
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("TTS 예제"),
//       ),
//       body: Column(
//         children: [
//           SizedBox(height: 150),
//           TextField(
//             controller: ttsController,
//             onTap: () {
//               TtsService().speak(ttsController.text);
//             },
//           ),
//           SizedBox(height: 10),
//           ElevatedButton(
//             onPressed: () => TtsService().speak(ttsController.text),
//             child: Text("재생"),
//           ),
//         ],
//       ),
//     );
//   }
// }
