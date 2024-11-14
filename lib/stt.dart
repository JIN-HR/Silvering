//stt.dart

import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
//import 'package:permission_handler/permission_handler.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;
  String _lastWords = "";
  bool get isInitialized => _speechEnabled;
  String get lastWords => _lastWords;
  bool get isListening => _speechToText.isListening;

  //초기화
  Future<void> initialize() async {
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) => print('Status: $status'),
      onError: (error) => print('Error: ${error.errorMsg}'),
    );
    //await _requestMicrophonePermission();
  }

  // 권한 요청
  // Future<void> _requestMicrophonePermission() async {
  //   final status = await Permission.microphone.request();
  //   print('Microphone permission status: $status');

  //   if (status.isDenied) {
  //     await Permission.microphone.request();
  //   } else if (status.isPermanentlyDenied) {
  //     await openAppSettings();
  //   }
  //   print('Microphone permission status: $status');
  // }

  // stt 시작
  Future<void> startListening(
      Function(SpeechRecognitionResult) onResult) async {
    if (_speechEnabled && !_speechToText.isListening) {
      await _speechToText.listen(
        onResult: onResult,
        listenFor: const Duration(seconds: 30),
        localeId: "ko-KR",
      );
    }
  }

  // stt 종료
  Future<void> stopListening() async {
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = "$_lastWords${result.recognizedWords}";
    print('$_lastWords');
  }
}
