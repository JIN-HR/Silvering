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
    print("TTS 요청됨: $text"); // TTS 호출 후 텍스트 출력



    var languages = await _tts.getLanguages;
    print("지원되는 언어들: $languages"); // 지원되는 언어 목록 출력
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}

