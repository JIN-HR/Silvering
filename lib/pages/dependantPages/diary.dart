import 'dart:convert';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:exif/exif.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../login.dart';
import 'package:cyber_project/tts.dart';
import 'package:cyber_project/stt.dart';

class DiaryPage extends StatefulWidget {
  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> with WidgetsBindingObserver {
  Uint8List? _imageData;
  bool _isLoading1 = false; // 로딩 상태 추가
  bool _isLoading2 = false;
  String? _errorMessage;
  bool _firstGenerated = false;
  bool _userResponse = false;
  bool _secondGenerated = false;

  String? _imagePath; // 이미지 파일 경로 저장
  String? _year; // 촬영 연도
  String? _month; // 촬영 월
  String? _day; // 촬영 일

  String caption = "";
  String userResponse = "";
  String expandedDiary = "";

  //tts 인스턴스
  TtsService ttsService = TtsService();

  //stt 인스턴스 생성
  SpeechService speechService = SpeechService();

  //stt 초기화
  @override
  void initState() {
    super.initState();
    speechService.initialize();
    WidgetsBinding.instance.addObserver(this); // Observer 등록
  }

  // 기존의 handleResponse 함수를 수정하여 API 호출을 포함
  Future<void> handleResponse() async {
    final Completer<void> completer = Completer<void>(); // 작업 완료 기다리는 Completer
    await ttsService.speak("응답을 시작합니다."); // TTS 안내 후

    try {
      await speechService.startListening((result) async {
        if (result.finalResult) {
          await speechService.stopListening();
          String response = result.recognizedWords;

          if (response.isNotEmpty) {
            await ttsService.speak("응답을 받았습니다.");
            print("user 응답: $response");
          }
          setState(() {
            userResponse = response ?? "";
            _userResponse = true;
          });
          completer.complete();
        }
      });
    } catch (error) {
      // error_no_match 오류 처리
      if (error.toString().contains('error_no_match')) {
        await ttsService.speak("음성 인식이 제대로 되지 않았습니다. 다시 응답해주세요.");
        handleResponse(); // 음성 인식을 다시 시작하여 재응답 받음
      } else {
        print("Error: $error");
      }
    }
    await completer.future; //Completer 완료될 때까지 대기
  }

//이미지 불러오기
  Future<void> _getImage() async {
    // 기존 데이터 초기화
    setState(() {
      _imageData = null;
      _imagePath = null;
      _year = null;
      _month = null;
      _day = null;
      caption = "";
      userResponse = "";
      expandedDiary = "";
      _firstGenerated = false;
      _secondGenerated = false;
      _userResponse = false;
    });
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.image, withData: true);

    if (result != null) {
      setState(() {
        _imageData = result.files.first.bytes;
        _imagePath = result.files.first.path; // 파일 경로 저장
      });

      if (_imagePath != null) {
        await _extractMetadata(_imagePath!); // 메타데이터 추출
      }
    } else {
      print('사진을 선택해주세요!'); // 기본 안내 메시지
    }
  }

  // 메타데이터 추출
  Future<void> _extractMetadata(String imagePath) async {
    try {
      // 파일의 바이트 데이터 읽기
      final fileBytes = File(imagePath).readAsBytesSync();

      // EXIF 메타데이터 추출
      final data = await readExifFromBytes(fileBytes);

      if (data.isEmpty) {
        print("No EXIF metadata found.");
      } else {
        // DateTimeOriginal 태그 확인 (촬영 날짜)
        final dateTimeOriginal =
            data['EXIF DateTimeOriginal']?.toString() ?? '촬영 날짜 없음';

        if (dateTimeOriginal != '촬영 날짜 없음') {
          // 촬영 날짜 'YYYY:MM:DD HH:MM:SS'
          final dateParts = dateTimeOriginal.split(' ')[0].split(':');
          setState(() {
            _year = dateParts[0];
            _month = dateParts[1];
            _day = dateParts[2];
          });
        }
        print("Year: $_year, Month: $_month, Day: $_day");
      }
    } catch (e) {
      print("메타데이터 추출 중 오류 발생: $e");
    }
  }

  Future<void> _uploadAndGetCaption() async {
    if (_imageData == null || _year == null || _month == null || _day == null) {
      setState(() {
        caption = '사진 또는 날짜 정보가 누락되었습니다!';
      });
      return;
    }

    setState(() {
      _isLoading1 = true;
      _errorMessage = null;
    });

    try {
      final uri =
          Uri.parse("http://10.240.124.55:5000/generate_caption"); // 로컬 서버 URL
      var request = http.MultipartRequest('POST', uri);

      // 이미지 파일을 multipart로 추가
      var multipartFile = http.MultipartFile.fromBytes('image', _imageData!,
          filename: 'upload.jpg');
      request.files.add(multipartFile);

      // year, month, day 추가
      request.fields['year'] = _year!;
      request.fields['month'] = _month!;
      request.fields['day'] = _day!;

      // 서버로 요청 전송
      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        print("서버 응답: $respStr"); // 디버깅용 출력 추가

        final jsonResponse = json.decode(respStr);

        setState(() {
          caption = jsonResponse['caption'] ?? "";
        });

        // TTS로 캡션 읽기
        if (caption.isNotEmpty) {
          TtsService().speak(caption); // 캡션이 있을 경우 읽기
        }
      } else {
        print('캡션 생성 실패: 상태 코드 ${response.statusCode}');
        setState(() {
          caption = '캡션 생성에 실패했습니다. 상태 코드: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('오류 발생: $e');
      setState(() {
        caption = '서버 요청 중 오류가 발생했습니다.';
      });
    } finally {
      setState(() {
        _isLoading1 = false;
        _firstGenerated = true;
      });
    }
  }

  Future<void> _expandDiary(String caption, String userResponse) async {
    setState(() {
      _isLoading2 = true;
      _errorMessage = null;
    });
    try {
      final response = await http.post(
          Uri.parse("http://10.240.123.200:5000/generate_expand_diary"),
          headers: {'Content-Type': 'application/json'},
          body:
              jsonEncode({"caption": caption, "user_response": userResponse}));

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        setState(() {
          expandedDiary = jsonResponse['expanded_diary'];
        });
        if (expandedDiary.isNotEmpty) {
          TtsService().speak(expandedDiary); // 캡션이 있을 경우 읽기
        }
      } else {
        print('일기 이어쓰기 실패: 상태 코드 ${response.statusCode}');
        setState(() {
          expandedDiary = '일기 이어쓰기에 실패했습니다. 상태 코드: ${response.statusCode}';
        });
      }
    } catch (e) {
      print('오류 발생: $e');
      setState(() {
        expandedDiary = '서버 요청 중 오류가 발생했습니다.';
      });
    } finally {
      setState(() {
        _isLoading2 = false;
        _secondGenerated = true;
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Observer 해제
    TtsService().stop(); // 화면이 사라질 때 TTS 중지
    super.dispose();
  }

  // AppLifecycleState 감지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      TtsService().stop(); // 앱이 백그라운드로 가거나 비활성화될 때 TTS 중지
    }
  }

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
              MaterialPageRoute(builder: (context) => LoginPage()),
              (Route<dynamic> route) => false,
            ); // home.dart로
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            iconSize: 40, // 아이콘 크기 설정
            onPressed: () {
              // 사용자 정보 페이지로 이동
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(height: 50),
              Text(
                '“대방어” 님의 일기 ',
                style: TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFFFA8072),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 30),
              _imageData == null
                  ? Text(
                      '사진을 선택해주세요!',
                      style: TextStyle(color: Colors.grey, fontSize: 20),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.memory(
                        _imageData!,
                        width: 300,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
              SizedBox(height: 50),
              ElevatedButton(
                onPressed: _getImage,
                child: Text(
                  '사진 선택하기',
                  style: TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w600), // 텍스트 크기 조정
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFA8072),
                  foregroundColor: Colors.white, // 텍스트 색상을 흰색으로 설정
                  fixedSize: Size(200, 60), // 버튼 크기 설정 (가로: 200, 세로: 60)
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30), // 둥근 모서리 설정
                  ),
                ),
              ),
              SizedBox(height: 20), // 버튼 간격 조정
              !_firstGenerated
                  ? ElevatedButton(
                      onPressed: () {
                        _uploadAndGetCaption();
                      },
                      child: Text(
                        '일기 쓰기',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600), // 텍스트 크기 조정
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFFA8072),
                        foregroundColor: Colors.white, // 텍스트 색상을 흰색으로 설정
                        fixedSize: Size(200, 60), // 버튼 크기 설정 (가로: 200, 세로: 60)
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30), // 둥근 모서리 설정
                        ),
                      ),
                    )
                  : Container(),
              SizedBox(height: 40),
              _isLoading1
                  ? CircularProgressIndicator() // 로딩 스피너
                  : Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40), // 좌우 여백 설정
                      child: Column(
                        children: [
                          caption.isNotEmpty
                              ? Text(
                                  '$caption',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFFFA8072),
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              : Container(),
                          SizedBox(height: 20),
                          caption.isNotEmpty && !_secondGenerated
                              ? ElevatedButton(
                                  onPressed: () async {
                                    await handleResponse();
                                    if (_userResponse) {
                                      _expandDiary(caption, userResponse);
                                      setState(() {});
                                    }
                                  },
                                  child: Text(
                                    '응답하기',
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight:
                                            FontWeight.w600), // 텍스트 크기 조정
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFFFA8072),
                                    foregroundColor:
                                        Colors.white, // 텍스트 색상을 흰색으로 설정
                                    fixedSize: Size(
                                        200, 60), // 버튼 크기 설정 (가로: 200, 세로: 60)
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          30), // 둥근 모서리 설정
                                    ),
                                  ),
                                )
                              : Container(),
                          SizedBox(height: 20),
                          _isLoading2
                              ? CircularProgressIndicator() // 로딩 스피너
                              : expandedDiary.isNotEmpty
                                  ? Text(
                                      '$expandedDiary',
                                      style: TextStyle(
                                        fontSize: 20,
                                        color: Color(0xFFFA8072),
                                      ),
                                      textAlign: TextAlign.center,
                                    )
                                  : Container(),
                        ],
                      )),

              SizedBox(height: 40),
              Text(
                'COPYRIGHT 2024 BY 달리는 대방어',
                style: TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
