// test.dart : 인지 능력 검사
import 'package:flutter/material.dart';
import 'package:cyber_project/tts.dart';
import 'package:cyber_project/stt.dart';
//test_eval.py에 전송
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'dependant_info.dart';
import 'dependentHome.dart';

class TestPage extends StatefulWidget {
  @override
  _TestPageState createState() => _TestPageState();
}

// 변수 초기화
class _TestPageState extends State<TestPage> {
  int currentIndex = -1; // -1 : 안내 화면, 0 : 연령 및 학력 입력
  int totalScore = 0; // 총 점수
  String calendarType = '양력'; // 양력/음력
  int selectedYear = 2000;
  int selectedMonth = 1;
  int selectedDay = 1;
  String educationLevel = '무학'; // 학력
  Map<String, int> categoryScores = {}; // 카테고리별 점수 저장

  //tts 인스턴스
  TtsService ttsService = TtsService();

  //stt 인스턴스 생성
  SpeechService speechService = SpeechService();

  //stt 초기화
  @override
  void initState() {
    super.initState();
    speechService.initialize();
  }

// 퀴즈 화면
  final List<Map<String, dynamic>> questions = [
    {
      'ques_num': 1,
      'category':'지남력',
      'question': '1. 오늘 날짜에 대한 질문입니다. \n 응답하기 버튼을 눌러주세요. \n (1) 오늘은 몇 년도인가요?',
      'ttsText': '오늘 날짜에 대한 질문입니다. 오늘은 몇 년도인지 응답하기 버튼을 누르고 연도를 말씀해주세요.',
      'options': [
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 1,
      'category':'지남력',
      'question': '1.  오늘 날짜에 대한 질문입니다. \n 응답하기 버튼을 눌러주세요. \n (2) 오늘은 몇 월인가요?',
      'ttsText': '이어지는 오늘 날짜에 대한 질문입니다. 오늘은 몇 월인지 응답하기 버튼을 누르고 달을 말씀해주세요.',
      'options': [
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 1,
      'category':'지남력',
      'question': '1. 오늘 날짜에 대한 질문입니다. \n 응답하기 버튼을 눌러주세요. \n (3) 오늘은 며칠인가요?',
      'ttsText': '이어지는 오늘 날짜에 대한 질문입니다. 오늘은 며칠인지 응답하기 버튼을 누르고 며칠인지를 말씀해주세요.',
      'options': [
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 1,
      'category':'지남력',
      'question': '1. 오늘 날짜에 대한 질문입니다. \n 응답하기 버튼을 눌러주세요. \n (4) 오늘은 무슨 요일인가요?',
      'ttsText': '마지막 오늘 날짜에 대한 질문입니다. 응답하기 버튼을 누르고 오늘이 무슨 요일인지를 말씀해주세요.',
      'options': [
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 2,
      'question':
      '2. 문장 외우기  \n 지금부터 외우셔야 하는 문장 하나를\n불러 드리겠습니다. \n 끝까지 잘 듣고 따라 해 보세요.',
      'ttsText':
      '2번 문제입니다. 지금부터 외우셔야 하는 문장 하나를 불러드리겠습니다. 한 번만 들려드리니, 끝까지 잘 듣고 따라해주세요.',
      'options': [
        {'text': '듣기'},
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 2,
      'question':
      '잘 하셨습니다. \n다시 한 번 불러드리겠습니다. \n 이번에도 다시 여쭈어 볼 테니 \n잘 듣고 따라 해 보세요.',
      'ttsText': '잘 하셨습니다. 다시 한 번 불러드리겠습니다. 이번에도 다시 여쭈어 볼 테니 잘 듣고 따라 해 보세요.',
      'options': [
        {'text': '듣기'},
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'question': '제가 이 문장을 나중에 여쭤 보겠습니다. 잘 기억하세요.',
      'ttsText': '제가 이 문장을 나중에 여쭤 보겠습니다. 잘 기억해주세요.',
      'options': [
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 3,
      'category':'주의력',
      'question':
      '3-1. 부르는 숫자 바로 따라 말하기\n제가 불러드리는 숫자를\n그대로 따라 해 주세요.\n한 번만 불러드릴 수 있으니\n잘 들어 주세요. ',
      'ttsText':
      '다음으로 3번 문제입니다.  제가 불러드리는 숫자를 그대로 따라 해 주세요. 한 번만 불러드릴 수 있으니 잘 들어 주세요. 6   9   7  3',
      'options': [
        {'text': '듣기'},
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 3,
      'category':'주의력',
      'question':
      '3-2. 부르는 숫자 바로 따라 말하기\n제가 불러드리는 숫자를\n그대로 따라 해 주세요.\n한 번만 불러드릴 수 있으니\n잘 들어 주세요. ',
      'ttsText':
      '다른 숫자를 불러드리겠습니다. 제가 불러드리는 숫자를 그대로 따라 해 주세요. 한 번만 불러드릴 수 있으니 잘 들어 주세요. 5  7  2  8  4',
      'options': [
        {'text': '듣기'},
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 4,
      'category':'주의력',
      'question': '4. 거꾸로 말하기 \n제가 불러드리는 말을\n끝에서부터 거꾸로 따라 해 주세요.',
      'ttsText': '다음 문제입니다. 제가 불러드리는 말을 끝에서부터 거꾸로 따라 해 주세요. 금,  수,  강,  산',
      'options': [
        {'text': '듣기'},
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'category':'시공간 기능',
      'question': '5.\n세 도형이 일정 순서로 나오고 있습니다.\n빈칸에 들어갈 도형은 무엇인가요?',
      'image': 'lib/pictures/Q7.png',
      'options': [
        {'text': '1 (네모)', 'score': 0},
        {'text': '2 (동그라미)', 'score': 1},
        {'text': '3 (세모)', 'score': 0},
      ],
    },
    {
      'category':'시공간 기능',
      'question': '6.\n네 칸 중 한 칸에 별이 하나 있고,\n별은 그림 순서대로 이동합니다.\n마지막 그림의 별은 어디있을까요?',
      'image': 'lib/pictures/Q8.png',
      'options': [
        {'text': '1', 'score': 0},
        {'text': '2', 'score': 1},
        {'text': '3', 'score': 0},
        {'text': '4', 'score': 0},
      ],
    },
    {
      'category':'시공간 기능',
      'question': '7.\n카드에 숫자 또는 계절이 적혀 있습니다.\n빨간 카드에 들어갈 말을 선택해주세요.',
      'image': 'lib/pictures/Q9.png',
      'options': [
        {'text': '4', 'score': 1},
        {'text': '5', 'score': 0},
        {'text': '여름', 'score': 0},
        {'text': '가을', 'score': 0},
      ],
    },
    {
      'category':'시공간 기능',
      'question': '7.\n카드에 숫자 또는 계절이 적혀 있습니다.\n파란 카드에 들어갈 말을 선택해주세요.',
      'image': 'lib/pictures/Q10.png',
      'options': [
        {'text': '4', 'score': 0},
        {'text': '5', 'score': 0},
        {'text': '여름', 'score': 1},
        {'text': '가을', 'score': 0},
      ],
    },
    {
      'category':'기억력',
      'question': '8-1. 기억력 \n 앞서 제가 어떤 사람의 이름을 말했는데,\n그이름은 무엇이었나요? ',
      'ttsText':
      '다음 문제입니다. 제가 앞서 외우라고 말씀드린 문장이 기억 나시나요? 그 문제에 대한 질문입니다. 앞서 제가 어떤 사람의 이름을 말했는데 누구일까요?',
      'options': [
        {'text': '영수', 'score': 0},
        {'text': '민수', 'score': 1},
        {'text': '진수', 'score': 0},
      ],
    },
    {
      'category':'기억력',
      'question': '8-2. 기억력 \n 무엇을 타고 갔습니까? ',
      'ttsText': '그 사람이 무엇을 타고 갔습니까? ',
      'options': [
        {'text': '버스', 'score': 0},
        {'text': '오토바이', 'score': 0},
        {'text': '자전거', 'score': 1},
      ],
    },
    {
      'category':'기억력',
      'question': '8-3. 기억력 \n 어디에 갔습니까? ',
      'ttsText': '그 사람이 어디에 갔습니까? ',
      'options': [
        {'text': '공원', 'score': 1},
        {'text': '놀이터', 'score': 0},
        {'text': '운동장', 'score': 0},
      ],
    },
    {
      'category':'기억력',
      'question': '8-4. 기억력 \n 몇 시부터 했습니까?',
      'ttsText': '몇 시부터 했습니까? ',
      'options': [
        {'text': '10시', 'score': 1},
        {'text': '11시', 'score': 0},
        {'text': '12시', 'score': 0},
      ],
    },
    {
      'category':'기억력',
      'question': '8-5. 기억력 \n 무엇을 했습니까?',
      'ttsText': '무엇을 했습니까?',
      'options': [
        {'text': '농구', 'score': 1},
        {'text': '축구', 'score': 0},
        {'text': '야구', 'score': 0},
      ],
    }
  ];

  // 시작
  void startTest() {
    setState(() {
      currentIndex = 0;
      //tts 안내
      ttsService.speak("검사를 시작합니다. \n 검사지는 보호자와 함꼐 수행하는 것을 권장드립니다.");
    });
  }

  // 다음 페이지(question)으로 넘어가기
  void nextQuestion(int score) {
    setState(() {
      totalScore += score;

      // 카테고리별 점수 계산
      String? category = questions[currentIndex]['category'];
      if (category != null) {
        categoryScores[category] = (categoryScores[category] ?? 0) + score;
      }

      if (currentIndex < questions.length - 1) {
        currentIndex++;
        String ttsPrompt = questions[currentIndex]['ttsText'] ?? ''; // TTS 텍스트 가져오기
        ttsService.speak(ttsPrompt); // TTS 안내
      } else {
        // 마지막 질문 이후 결과 페이지로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultPage(
              score: totalScore,
              categoryScores: categoryScores, // 추가
            ),
          ),
        ).then((_) {
          ttsService.speak("검사가 완료되었습니다. 총 점수는 $totalScore점입니다.");
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: buildAppBar(context),
      body: Center(
        child: currentIndex == -1
            ? buildIntroScreen()
            : (currentIndex == 0 ? buildInputScreen() : buildQuestionPage()),
      ),
    );
  }

  // 공통 AppBar 위젯
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFFFA8072),
      leading: IconButton(
        icon: Icon(Icons.home, color: Colors.white),
        iconSize: 40,
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => Dependenthome()),
                (Route<dynamic> route) => false,
          );
        },
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.person, color: Colors.white),
          iconSize: 40,
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                  builder: (context) => DependentInfoPage()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ],
    );
  }

  // 검사 시작 화면
  Widget buildIntroScreen() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '치매 검사를 시작합니다.\n안내를 잘 읽고\n검사 시작하기를 눌러주세요.\n\n'
                '해당 검사는 참고용입니다.\n정확한 진단을 위해서는 \n병원을 방문하세요.\n',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFA8072),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            onPressed: startTest,
            child: Text(
              '검사 시작하기',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 개인 정보 입력 화면
  Widget buildInputScreen() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '개인 정보 입력',
            style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFA8072)),
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: Text(
              '\n생년월일',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: calendarType,
                onChanged: (value) {
                  setState(() {
                    calendarType = value!;
                  });
                },
                items: ['양력', '음력'].map((String type) {
                  return DropdownMenuItem(value: type, child: Text(type));
                }).toList(),
              ),
              SizedBox(width: 15),
              DropdownButton<int>(
                value: selectedYear,
                onChanged: (value) {
                  setState(() {
                    selectedYear = value!;
                  });
                },
                items: List.generate(
                  120,
                      (index) => 1900 + index,
                ).map((year) {
                  return DropdownMenuItem(value: year, child: Text('$year'));
                }).toList(),
              ),
              Text(' 년 '),
              DropdownButton<int>(
                value: selectedMonth,
                onChanged: (value) {
                  setState(() {
                    selectedMonth = value!;
                  });
                },
                items: List.generate(12, (index) => index + 1).map((month) {
                  return DropdownMenuItem(value: month, child: Text('$month'));
                }).toList(),
              ),
              Text(' 월 '),
              DropdownButton<int>(
                value: selectedDay,
                onChanged: (value) {
                  setState(() {
                    selectedDay = value!;
                  });
                },
                items: List.generate(31, (index) => index + 1).map((day) {
                  return DropdownMenuItem(value: day, child: Text('$day'));
                }).toList(),
              ),
              Text(' 일'),
            ],
          ),
          SizedBox(height: 20),
          Align(
            alignment: Alignment.center,
            child: Text(
              '\n학력',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ),
          SizedBox(height: 10),
          DropdownButton<String>(
            value: educationLevel,
            onChanged: (value) {
              setState(() {
                educationLevel = value!;
              });
            },
            items: ['무학', '초등학교 졸', '중학교 졸', '고등학교 졸', '대학교 졸업 이상']
                .map((String level) {
              return DropdownMenuItem(value: level, child: Text(level));
            }).toList(),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFFA8072),
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            ),
            onPressed: () {
              nextQuestion(0);
            },
            child: Text(
              '다음',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // 기존의 handleResponse 함수를 수정하여 API 호출을 포함
  void handleResponse({String? buttonText}) async {
    await ttsService.speak("응답을 시작합니다."); // TTS 안내 후

    try {
      await speechService.startListening((result) async {
        if (result.finalResult) {
          await speechService.stopListening();
          String userResponse = result.recognizedWords;

          if (userResponse.isNotEmpty) {
            ttsService.speak("응답을 받았습니다.");
            print("user 응답: $userResponse");

            // 현재 질문의 questionNumber 가져오기
            var currentQuestion = questions[currentIndex];
            int? questionNumber = currentQuestion.containsKey('ques_num')
                ? currentQuestion['ques_num']
                : null;

            if (questionNumber != null) {
              print("sendResponseAndGetScore 호출 준비 중: $userResponse, $questionNumber");

              // ques_num이 있을 경우 API로 점수 요청
              int score =
              await sendResponseAndGetScore(userResponse, questionNumber);
              print("score: $score");
              proceedToNextQuestion(score); // 점수에 따라 다음 질문으로 이동
            } else if (buttonText == '넘어가기') {
              // "넘어가기" 버튼인 경우 다음 질문으로 바로 이동
              proceedToNextQuestion(0);
            } else {
              // ques_num이 없을 경우, 선택지에서 score를 가져와서 사용
              int score = currentQuestion['options'].firstWhere(
                      (option) => option['text'] == buttonText)['score'];
              proceedToNextQuestion(score);
            }
          } else {
            ttsService.speak("응답을 받지 못하였습니다. 다시 한 번 말씀해주세요.");
            handleResponse(); // 음성 인식을 다시 시작하여 응답을 받음
          }
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
  }

  // 응답의 유효성을 확인하는 함수
  // Future<bool> checkResponseValidity(String userResponse) async {
  //   var url = Uri.parse('http://10.240.134.72:5000/check_validity');
  //   var httpResponse = await http.post(url, headers: {
  //     "Content-Type": "application/json"
  //   }, body: json.encode({"response": userResponse}));
  //
  //   print("유효성 확인 서버 응답: ${httpResponse.body}"); // 유효성 응답 로그 확인
  //
  //   if (httpResponse.statusCode == 200) {
  //     var jsonResponse = jsonDecode(httpResponse.body);
  //     return jsonResponse['isValid'] ?? false; // 유효성 결과 반환
  //   } else {
  //     throw Exception('Failed to validate response');
  //   }
  // }

  // 기존의 handleResponse 함수를 수정하여 API 호출을 포함하고, '듣기' 버튼도 구현
  void handleListen() async {
    // '듣기' 버튼을 누르면 TTS로 문장을 읽어줍니다.
    await ttsService.speak("민수는     자전거를 타고       공원에 가서     11시부터     야구를 했다");
  }

  // 서버로부터 점수를 요청하고 받아오는 함수
  Future<int> sendResponseAndGetScore(String userResponse, int questionNumber) async {
    var url = Uri.parse('http://10.0.0.2:5000/evaluate');
    print("서버 요청 URL: $url");

    try {
      print("서버로 데이터 전송 중: $userResponse, $questionNumber");
      var httpResponse = await http.post(url,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "text": userResponse,
            "question_number": questionNumber,
          }));

      print("서버 응답 상태 코드: ${httpResponse.statusCode}");
      print("서버 응답 본문: ${httpResponse.body}");

      if (httpResponse.statusCode == 200) {
        var jsonResponse = jsonDecode(httpResponse.body);
        print("JSON 응답: $jsonResponse");
        if (jsonResponse.containsKey('evaluation')) {
          return jsonResponse['evaluation'] as int;
        } else {
          print("Error: 응답에 'evaluation' 키가 없습니다.");
          return 0;
        }
      } else {
        print("서버 오류: ${httpResponse.body}");
        return 0;
      }
    } catch (e) {
      print("서버와 통신 중 오류 발생: $e");
      return 0;
    }
  }



  // 다음 질문으로 진행하는 함수
  void proceedToNextQuestion(int score) {
    setState(() {
      // 현재 질문 가져오기
      var currentQuestion = questions[currentIndex];

      // 카테고리가 존재하면 점수 계산
      if (currentQuestion.containsKey('category')) {
        String category = currentQuestion['category'];
        categoryScores[category] = (categoryScores[category] ?? 0) + score;
      } else {
        print("카테고리가 없는 질문입니다. 점수를 추가하지 않습니다.");
      }

      // 총점 업데이트
      totalScore += score;

      // 다음 질문으로 이동
      if (currentIndex < questions.length - 1) {
        currentIndex++;
        ttsService.speak("확인되었습니다. 다음 질문으로 넘어가겠습니다.").then((_) {
          String ttsPrompt =
              questions[currentIndex - 1]['ttsText'] ?? "다음 질문을 확인하세요.";
          ttsService.speak(ttsPrompt);
        });
      } else {
        // 검사 완료: Firestore에 저장 후 결과 페이지로 이동
        ttsService.speak("검사가 완료되었습니다.").then((_) async {
          //await saveTestResultsToFirestore(totalScore, categoryScores); // Firestore 저장
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultPage(
                score: totalScore,
                categoryScores: categoryScores,
              ),
            ),
          );
        });
      }
    });
  }




  // // 다음 질문으로 진행하는 함수
  // void proceedToNextQuestion(int score) {
  //   setState(() {
  //     // 현재 질문 가져오기
  //     var currentQuestion = questions[currentIndex];
  //
  //     // 카테고리가 존재하면 점수 계산
  //     if (currentQuestion.containsKey('category')) {
  //       String category = currentQuestion['category'];
  //       categoryScores[category] = (categoryScores[category] ?? 0) + score;
  //     } else {
  //       print("카테고리가 없는 질문입니다. 점수를 추가하지 않습니다.");
  //     }
  //
  //     // 총점 업데이트
  //     totalScore += score;
  //
  //     // 다음 질문으로 이동
  //     if (currentIndex < questions.length - 1) {
  //       currentIndex++;
  //       ttsService.speak("확인되었습니다. 다음 질문으로 넘어가겠습니다.").then((_) {
  //         String ttsPrompt =
  //             questions[currentIndex - 1]['ttsText'] ?? "다음 질문을 확인하세요.";
  //         ttsService.speak(ttsPrompt);
  //       });
  //     } else {
  //       // 검사 완료: Firestore에 저장 후 결과 페이지로 이동
  //       ttsService.speak("검사가 완료되었습니다.").then((_) async {
  //         //await saveTestResultsToFirestore(totalScore, categoryScores); // Firestore 저장
  //         Navigator.push(
  //           context,
  //           MaterialPageRoute(
  //             builder: (context) => ResultPage(
  //               score: totalScore,
  //               categoryScores: categoryScores,
  //             ),
  //           ),
  //         );
  //       });
  //     }
  //   });
  // }
  // Future<void> saveTestResultsToFirestore(
  //     int score, Map<String, int> categoryScores) async {
  //   final currentUser = FirebaseAuth.instance.currentUser;
  //
  //   if (currentUser == null) {
  //     print('로그인된 사용자가 없습니다.');
  //     return;
  //   }
  //
  //   try {
  //     final userDocRef = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);
  //
  //     // 사용자 문서 확인
  //     final userDocSnapshot = await userDocRef.get();
  //
  //     if (!userDocSnapshot.exists) {
  //       print('사용자 문서를 찾을 수 없습니다.');
  //       return;
  //     }
  //
  //     final userData = userDocSnapshot.data();
  //
  //     if (userData != null && userData['role'] == 'dependent') {
  //       await userDocRef.update({
  //         'lastTestScore': score,
  //         'categoryScores': categoryScores,
  //         'lastTestDate': FieldValue.serverTimestamp(),
  //       });
  //
  //       print('테스트 결과가 성공적으로 저장되었습니다.');
  //     } else if (userData != null && userData['role'] == 'guardian') {
  //       print('현재 사용자는 보호자입니다. 테스트 결과를 저장할 수 없습니다.');
  //     } else {
  //       print('알 수 없는 사용자 역할입니다: ${userData?['role']}');
  //     }
  //   } catch (e) {
  //     print('테스트 결과 저장 중 오류 발생: $e');
  //   }
  // }

  // 퀴즈 화면에서 '듣기', '응답하기', '넘어가기' 버튼 처리를 구현
  Widget buildQuestionPage() {
    final question = questions[currentIndex - 1];
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            question['question'],
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          if (question.containsKey('image')) ...[
            SizedBox(height: 10),
            Image.asset(
              question['image'],
              width: 380,
              height: 120,
              fit: BoxFit.contain,
            ),
          ],
          SizedBox(height: 10),
          ...question['options'].map<Widget>((option) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFA8072),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(300, 40),
                ),
                onPressed: () {
                  String buttonText = option['text'];
                  if (buttonText == '듣기') {
                    handleListen(); // '듣기' 버튼 기능 호출
                  } else if (buttonText == '넘어가기') {
                    // '넘어가기' 버튼일 경우 바로 다음 질문으로 이동
                    proceedToNextQuestion(0);
                  } else if (option.containsKey('score')) {
                    int score = option['score']; // 선택지의 점수 가져오기
                    proceedToNextQuestion(score); // 점수를 반영하며 다음 질문으로 이동
                  } else {
                    // '응답하기' 버튼 처리
                    handleResponse(buttonText: buttonText);
                  }
                },
                child: Text(
                  option['text'],
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}

class ResultPage extends StatelessWidget {
  final int score;
  final Map<String, int> categoryScores;

  ResultPage({required this.score, required this.categoryScores});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFFFA8072),
        leading: IconButton(
          icon: Icon(Icons.home, color: Colors.white),
          iconSize: 40,
          onPressed: () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Dependenthome()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.person, color: Colors.white),
            iconSize: 40,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DependentInfoPage(),
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Center(
              child: Text(
                '점수 : $score / 16점',
                style: TextStyle(fontSize: 30, color: Color(0xFFFA8072), fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 30),
            Text(
              '= 카테고리별 점수 =',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            ...categoryScores.entries.map((entry) {
              return Text(
                '${entry.key} : ${entry.value}점',
                style: TextStyle(fontSize: 20, color: Colors.grey),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}