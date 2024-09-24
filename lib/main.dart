///////////////////////////////////////////////////////////////////////////////
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:io';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '달리는 대방어',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CaptioningApp(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pushNamed(context, '/second');
          },
          child: Text('Go to Second Page'),
        ),
      ),
    );
  }
}

class CaptioningApp extends StatefulWidget {
  @override
  _CaptioningAppState createState() => _CaptioningAppState();
}

class _CaptioningAppState extends State<CaptioningApp> {
  Uint8List? _imageData;
  String _caption = "";

  Future<void> _getImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);

    if (result != null) {
        print('Image selected: ${result.files.first.name}');
        print('Image bytes: ${result.files.first.bytes?.length}');
      setState(() {
        _imageData = result.files.first.bytes;
      });
    } else {
      print('사진을 선택해주세요!'); // 기본 안내 메시지
    }
  }

  Future<void> _uploadAndGetCaption() async {
    if (_imageData == null) return; // 예외 처리 (실패 시 안내 메시지 표출)

    try {
      final uri = Uri.parse("http://10.0.2.2:5000/generate_caption");

      var request = http.MultipartRequest('POST', uri);
      var multipartFile = http.MultipartFile.fromBytes('image', _imageData!, filename: 'upload.jpg');

      request.files.add(multipartFile);

      request.headers.addAll({
        "Content-Type": "application/json",
      });

      var response = await request.send();

      if (response.statusCode == 200) {
        final respStr = await response.stream.bytesToString();
        final jsonResponse = json.decode(respStr);

        setState(() {
          _caption = jsonResponse['caption'];
        });
      } else {
        print('Failed to generate caption. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error occurred: $e');
      setState(() {
        _caption = '일기 생성에 실패했습니다.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('달리는 대방어'),
      ),
      body: SingleChildScrollView(
        child : Center (
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
            ],
          ),
        )

      ),
    );
  }
}

