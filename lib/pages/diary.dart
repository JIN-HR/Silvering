import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:exif/exif.dart';  // EXIF 메타데이터 추출 패키지

class DiaryPage extends StatefulWidget {
  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  Uint8List? _imageData;
  String _caption = "";
  String? _imagePath;  // 이미지 파일 경로 저장
  String? _year;  // 촬영 연도
  String? _month; // 촬영 월
  String? _day;   // 촬영 일

  Future<void> _getImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);

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
        final dateTimeOriginal = data['EXIF DateTimeOriginal']?.toString() ?? '촬영 날짜 없음';

        if (dateTimeOriginal != '촬영 날짜 없음') {
          // 촬영 날짜 형식이 'YYYY:MM:DD HH:MM:SS'이므로 이를 분리
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
    if (_imageData == null || _year == null || _month == null || _day == null) return; // 예외 처리 (이미지 또는 날짜 정보가 없을 때)

    try {
      final uri = Uri.parse("http://10.0.2.2:5000/generate_caption");  // 로컬 서버 URL

      var request = http.MultipartRequest('POST', uri);

      // 이미지 파일을 multipart로 추가
      var multipartFile = http.MultipartFile.fromBytes('image', _imageData!, filename: 'upload.jpg');
      request.files.add(multipartFile);

      // year, month, day 데이터를 함께 추가
      request.fields['year'] = _year!;   // 연도 추가
      request.fields['month'] = _month!; // 월 추가
      request.fields['day'] = _day!;     // 일 추가

      // 서버로 요청 전송
      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final jsonResponse = json.decode(respStr);

        setState(() {
          _caption = jsonResponse['caption'];  // 서버로부터 받은 캡션 저장
        });
      } else {
        print('Failed to generate caption. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        _caption = '일기 생성에 실패했습니다.';  // 예외 처리
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('일기 쓰기'),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _imageData == null
                  ? Text('사진을 선택해주세요!')
                  : Image.memory(_imageData!),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getImage,
                child: Text('사진 선택하기'),
              ),
              ElevatedButton(
                onPressed: _uploadAndGetCaption,
                child: Text('일기 쓰기'),
              ),
              SizedBox(height: 20),
              _caption.isNotEmpty ? Text('Caption: $_caption') : Container(),
              SizedBox(height: 20),
              // 촬영 날짜 출력
              if (_year != null && _month != null && _day != null)
                Text('촬영 날짜: $_year년 $_month월 $_day일'),
            ],
          ),
        ),
      ),
    );
  }
}
