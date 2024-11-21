// test.dart : 인지 능력 검사
import 'package:flutter/material.dart';
import 'home.dart';
import 'userinfo.dart';
import 'package:cyber_project/tts.dart';
import 'package:cyber_project/stt.dart';
//test_eval.py에 전송
import 'package:http/http.dart' as http;
import 'dart:convert';

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

  //tts 인스턴스
  TtsService ttsService = TtsService();

  //stt 인스턴스 생성
  SpeechService speechService = SpeechService();

  //stt 초기화
  @override
  void initState() {
    super.initState();
    speechService.initialize();

    // currentIndex가 -1일 때 음성을 자동으로 재생
    if (currentIndex == -1) {
      Future.delayed(Duration.zero, () {
        ttsService.speak("검사를 시작합니다. 검사지는 보호자와 함께 수행하는 것을 권장드립니다.");
      });
    }
  }

// 퀴즈 화면
  final List<Map<String, dynamic>> questions = [
    {
      'ques_num': 1,
      'question': '1. 오늘 날짜에 대한 질문입니다. \n 응답하기 버튼을 눌러주세요. \n (1) 오늘은 몇 년도인가요?',
      'ttsText': '오늘 날짜에 대한 질문입니다. 오늘은 몇 년도인지 응답하기 버튼을 누르고 연도를 말씀해주세요.',
      'options': [
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 1,
      'question': '1.  오늘 날짜에 대한 질문입니다. \n 응답하기 버튼을 눌러주세요. \n (2) 오늘은 몇 월인가요?',
      'ttsText': '이어지는 오늘 날짜에 대한 질문입니다. 오늘은 몇 월인지 응답하기 버튼을 누르고 몇 월인지를 말씀해주세요.',
      'options': [
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 1,
      'question': '1. 오늘 날짜에 대한 질문입니다. \n 응답하기 버튼을 눌러주세요. \n (3) 오늘은 며칠인가요?',
      'ttsText': '이어지는 오늘 날짜에 대한 질문입니다. 오늘은 며칠인지 응답하기 버튼을 누르고 며칠인지를 말씀해주세요.',
      'options': [
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 1,
      'question': '1. 오늘 날짜에 대한 질문입니다. \n 응답하기 버튼을 눌러주세요. \n (4) 오늘은 무슨 요일인가요?',
      'ttsText': '마지막 오늘 날짜에 대한 질문입니다. 응답하기 버튼을 누르고 오늘이 무슨 요일인지를 말씀해주세요.',
      'options': [
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 2,
      'question': '2. 문장 외우기  \n 지금부터 외우셔야 하는 문장 하나를 불러드리겠습니다. \n 끝까지 잘 듣고 따라 해 보세요.',
      'ttsText': '2번 문제입니다. 지금부터 외우셔야 하는 문장 하나를 불러드리겠습니다. 한 번만 들려드리니, 끝까지 잘 듣고 따라해주세요.',
      'options': [
        {'text': '듣기'},
        {'text': '말하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 2,
      'question': '잘 하셨습니다. 다시 한 번 불러드리겠습니다. \n 이번에도 다시 여쭈어 볼 테니 잘 듣고 따라 해 보세요.',
      'ttsText':'잘 하셨습니다. 다시 한 번 불러드리겠습니다.  이번에도 다시 여쭈어 볼 테니 잘 듣고 따라 해 보세요.',
      'options': [
        {'text': '듣기'},
        {'text': '넘어가기'}
      ],
    },
    {
      'question': '제가 이 문장을 나중에 여쭤 보겠습니다. 잘 기억하세요.',
      'ttsText':'제가 이 문장을 나중에 여쭤 보겠습니다. 잘 기억해주세요.',
      'options': [
        {'text': '넘어가기'}
      ],
    },
    {
      'ques_num': 3,
      'question': '3-1. 부르는 숫자 바로 따라 말하기 \n 제가 불러드리는 숫자를 그대로 따라 해 주세요. \n 한 번만 불러드릴 수 있으니 잘 들어 주세요. ',
      'ttsText':'다음으로 3번 문제입니다.  제가 불러드리는 숫자를 그대로 따라 해 주세요. 한 번만 불러드릴 수 있으니 잘 들어 주세요. 6   9   7  3',
      'options': [
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 3,
      'question': '3-2. 부르는 숫자 바로 따라 말하기 \n 제가 불러드리는 숫자를 그대로 따라 해 주세요. \n 한 번만 불러드릴 수 있으니 잘 들어 주세요. ',
      'ttsText':'다른 숫자를 불러드리겠습니다. 제가 불러드리는 숫자를 그대로 따라 해 주세요. 한 번만 불러드릴 수 있으니 잘 들어 주세요. 5  7  2  8  4',
      'options': [
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 4,
      'question': '4. 거꾸로 말하기 \n 제가 불러드리는 말을 끝에서부터 거꾸로 따라 해 주세요.',
      'ttsText':'다음 문제입니다. 제가 불러드리는 말을 끝에서부터 거꾸로 따라 해 주세요. 금,  수,  강,  산',
      'options': [
        {'text': '응답하기'},
        {'text': '넘어가기'},
      ],
    },
    {
      'ques_num': 5,
      'question': '5. 시공간 기능 ',
      'ttsText':'',
      'options': [
        {'text': '선택지 1', 'score': 1},
        {'text': '선택지 2', 'score': 1},
        {'text': '선택지 3', 'score': 1},
      ],
    },
    {

      'question': '6-1. 도형 추론 \n 아래 그림을 보면 모양이 정해진 순서로 나옵니다. \n 모양들을 보면서 어떤 순서로 나오는지 생각해 보세요. \n 자, 네모, 동그라미, 세모, 네모, 빈칸 세모. \n 그렇다면 여기 빈 칸에는 무엇이 들어가야 할까요?',
      'ttsText':'다음으로 도형 추론 문제입니다. 문제를 잘 듣고 보기 중 하나를 선택해 주세요. 아래 그림을 보면 모양이 정해진 순서로 나옵니다.  모양들을 보면서 어떤 순서로 나오는지 생각해 보세요.자, 네모, 동그라미, 세모, 네모, 빈칸 세모. 그렇다면 여기 빈 칸에는 무엇이 들어가야 할까요? 화면의 보기 중 하나를 선택해주세요.  ',
      'image' : 'lib/pictures/Q7.png',
      'options': [
        {'text': '1 (네모)', 'score': 0},
        {'text': '2 (동그라미)', 'score': 1},
        {'text': '3 (세모)', 'score': 0},
      ],
    },
    {
      'question': '6-2. 도형 추론 \n 여기 네 칸 중의 한 칸에 별이 있습니다. \n 별이 이렇게 다른 위치로 이동합니다. \n 어떤 식으로 이동하는지 잘 생각해 보십시오 \n 여기서는 네 칸 중 별이 어디에 위치하게 될까요?',
      'ttsText':'다음 도형 문제입니다. 문제를 잘 듣고 보기 중 하나를 선택해 주세요. 여기 네 칸 중의 한 칸에 별이 있습니다. 별이 이렇게 다른 위치로 이동합니다. 어떤 식으로 이동하는지 잘 생각해 보십시오. 마지막에는 네 칸 중 별이 어디에 위치하게 될까요? 보기 중 하나를 선택하세요. ',
      'image' : 'lib/pictures/Q8.png',
      'options': [
        {'text': '1', 'score': 0},
        {'text': '2', 'score': 1},
        {'text': '3', 'score': 0},
        {'text': '4', 'score': 0},
      ],
    },
    {
      'question': '6-3. 도형 추론 \n 카드에 숫자와 계절이 하나씩 적혀 있습니다. \n 1, 봄, 2, 여름, 이렇게 연결되어 나갑니다.  \n 빨간색 카드에 들어갈 말을 선택해주세요.',
      'ttsText':'다음 문제입니다. 문제를 잘 듣고 보기 중 하나를 선택해 주세요. 카드에 숫자와 계절이 하나씩 적혀 있습니다. 1, 봄, 2, 여름, 이렇게 연결되어 나갑니다. 빨간색 카드에 들어갈 말을 보기에서 선택하세요. ',
      'image' : 'lib/pictures/Q9.png',
      'options': [
        {'text': '4', 'score': 1},
        {'text': '5', 'score': 0},
        {'text': '여름', 'score': 0},
        {'text': '가을', 'score': 0},
      ],
    },
    {
      'question': '6-3. 도형 추론 \n 카드에 숫자와 계절이 하나씩 적혀 있습니다. \n 1, 봄, 2, 여름, 이렇게 연결되어 나갑니다.  \n 파란색 카드에 들어갈 말을 선택해주세요.',
      'ttsText':'다음으로는, 파란색 카드에 들어갈 말을 보기에서 선택하세요. ',
      'image' : 'lib/pictures/Q10.png',
      'options': [
        {'text': '4', 'score': 0},
        {'text': '5', 'score': 0},
        {'text': '여름', 'score': 1},
        {'text': '가을', 'score': 0},
      ],
    },
    {
      'ques_num': 7,
      'question': '7-1. 기억력 \n 앞서 제가 어떤 사람의 이름을 말했는데 누구일까요? ',
      'ttsText':'다음 문제입니다. 제가 앞서 외우라고 말씀드린 문장이 기억 나시나요? 그 문제에 대한 질문입니다. 앞서 제가 어떤 사람의 이름을 말했는데 누구일까요?',
      'options': [
        {'text': '영수', 'score': 0},
        {'text': '민수', 'score': 1},
        {'text': '진수', 'score': 0},
      ],
    },
    {
      'ques_num': 7,
      'question': '7-2. 기억력 \n 무엇을 타고 갔습니까? ',
      'ttsText':'그 사람이 무엇을 타고 갔습니까? ',
      'options': [
        {'text': '버스', 'score': 0},
        {'text': '오토바이', 'score': 0},
        {'text': '자전거', 'score': 1},
      ],
    },
    {
      'ques_num': 7,
      'question': '7-3. 기억력 \n 어디에 갔습니까? ',
      'ttsText':'그 사람이 어디에 갔습니까? ',
      'options': [
        {'text': '공원', 'score': 1},
        {'text': '놀이터', 'score': 0},
        {'text': '운동장', 'score': 0},
      ],
    },
    {
      'ques_num': 7,
      'question': '7-4. 기억력 \n 몇 시부터 했습니까?',
      'ttsText':'몇 시부터 했습니까? ',
      'options': [
        {'text': '10시', 'score': 1},
        {'text': '11시', 'score': 0},
        {'text': '12시', 'score': 0},
      ],
    },
    {
      'ques_num': 7,
      'question': '7-5. 기억력 \n 무엇을 했습니까?',
      'ttsText':'무엇을 했습니까?',
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
      currentIndex = 0; // 질문 페이지로 이동
    });
  }

  // 다음 페이지(question)으로 넘어가기
  void nextQuestion(int score) {
    setState(() {
      totalScore += score;
      if (currentIndex < questions.length) {
        currentIndex++; // currentIndex로만 페이지 이동 관리
        String ttsPrompt = questions[currentIndex-1]['ttsText'] ?? "다음 질문을 확인하세요.";
        ttsService.speak(ttsPrompt);
      } else {
        ttsService.speak("검사가 완료되었습니다. 총 점수는 $totalScore점입니다.").then((_) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ResultPage(score: totalScore)),
          );
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
            ? buildIntroScreen() // currentIndex가 -1일 때 안내 화면 표시
            : (currentIndex == 0 ? buildInputScreen() : buildQuestionPage()),
      ),
    );
  }


  // 공통 AppBar 위젯
  PreferredSizeWidget buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Color(0xFF5586E3),
      leading: IconButton(
        icon: Icon(Icons.home, color: Colors.white),
        iconSize: 40,
        onPressed: () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
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
              MaterialPageRoute(builder: (context) => InfoPage()),
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
            '치매 검사를 시작합니다.\n안내를 읽고 검사 시작하기를 눌러주세요.\n\n'
                '해당 검사는 참고용입니다.\n정확한 진단을 위해서는 병원을 방문하세요.\n',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, color: Colors.grey),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5586E3),
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
            style: TextStyle(fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5586E3)),
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
            items: ['무학', '초등학교 졸', '중학교 졸', '고등학교 졸', '대학교 졸업 이상'].map((
                String level) {
              return DropdownMenuItem(value: level, child: Text(level));
            }).toList(),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF5586E3),
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

  void handleResponse({String? buttonText}) async {
    // 현재 질문을 가져오기
    var currentQuestion = questions[currentIndex];
    int score = 0; // 기본 점수

    if (buttonText == '말하기') {
      // '말하기' 버튼을 눌렀을 때: STT 사용하여 음성 받기, score = 0
      await speechService.startListening((result) async {
        if (result.finalResult) {
          await speechService.stopListening();
          String userResponse = result.recognizedWords;
          if (userResponse.isNotEmpty) {
            ttsService.speak("응답을 받았습니다.");
            proceedToNextQuestion(score); // score는 0으로 진행
          } else {
            ttsService.speak("응답을 받지 못하였습니다. 다시 한 번 말씀해주세요.");
            handleResponse(buttonText: buttonText); // STT 다시 시작
          }
        }
      });
    } else if (buttonText == '넘어가기') {
      // '넘어가기' 버튼을 눌렀을 때: STT와 API 둘 다 사용하지 않음, score = 0
      proceedToNextQuestion(score);
    } else if (buttonText == '듣기') {
      // '듣기' 버튼을 눌렀을 때: TTS로 문제 읽기, score = 0
      await ttsService.speak(currentQuestion['ttsText'] ?? "다음 문제를 들으세요.");
    } else if (buttonText == '응답하기') {
      await ttsService.speak("응답을 시작합니다."); // 응답 시작 안내 TTS
      await Future.delayed(Duration(milliseconds: 1500)); // 지연 시간 추가

      // 이후 STT로 사용자 음성 받기
      await speechService.startListening((result) async {
        if (result.finalResult) {
          await speechService.stopListening();
          String userResponse = result.recognizedWords;
          print("사용자 응답: $userResponse");

          if (userResponse.isNotEmpty) {
            ttsService.speak("응답을 받았습니다.");
            await Future.delayed(Duration(milliseconds: 1000)); // 짧은 지연 추가
            int questionNumber = currentQuestion['ques_num'];
            score = await sendResponseAndGetScore(userResponse, questionNumber);
            proceedToNextQuestion(score);
          } else {
            await ttsService.speak("응답을 받지 못하였습니다. 다시 한 번 말씀해주세요.");
            handleResponse(buttonText: buttonText); // 재시도
          }
        }
      });
    }
    else {
      // 선택지의 점수를 바로 반영하는 경우 (STT와 API 둘 다 사용하지 않음)
      score = currentQuestion['options']
          .firstWhere((option) => option['text'] == buttonText, orElse: () => {'score': 0})['score'];
      proceedToNextQuestion(score);
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
    var url = Uri.parse('http://10.240.164.49:5000/evaluate');

    var httpResponse = await http.post(url, headers: {
      "Content-Type": "application/json"
    }, body: json.encode({
      "text": userResponse,
      "question_number": questionNumber  // 질문 번호 추가
    }));

    print("서버 응답: ${httpResponse.body}"); // 서버 응답 전체를 출력하여 확인

    if (httpResponse.statusCode == 200) {
      var jsonResponse = jsonDecode(httpResponse.body);
      if (jsonResponse.containsKey('evaluation')) {
        return jsonResponse['evaluation'] as int;
      } else {
        print("Error: 응답에 'evaluation' 키가 없습니다.");
        return 0;
      }
    } else {
      throw Exception('Failed to load score');
    }
  }


  // 다음 질문으로 진행하는 함수
  // 다음 질문으로 진행하는 함수
  void proceedToNextQuestion(int score) async {
    setState(() {
      totalScore += score;
      currentIndex++;
    });

    if (currentIndex < questions.length) {
      await ttsService.speak("확인되었습니다. 다음 질문으로 넘어가겠습니다.");
      String ttsPrompt = questions[currentIndex-1]['ttsText'] ?? "다음 질문을 확인하세요.";
      await ttsService.speak(ttsPrompt);
    } else {
      await ttsService.speak("검사가 완료되었습니다.");
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ResultPage(score: totalScore)),
      );
    }
  }





  // 퀴즈 화면에서 '듣기', '응답하기', '넘어가기' 버튼 처리를 구현
  Widget buildQuestionPage() {
    final question = questions[currentIndex-1];
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            question['question'],
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, color: Colors.grey),
          ),
          if (question.containsKey('image')) ...[
            SizedBox(height: 10),
            Image.asset(
              question['image'],
              width: 380,
              height: 180,
              fit: BoxFit.contain,
            ),
          ],
          SizedBox(height: 20),
          ...question['options'].map<Widget>((option) {
            return Container(
              margin: EdgeInsets.symmetric(vertical: 5),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF5586E3),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(300, 50),
                ),
                onPressed: () {
                  String buttonText = option['text'];
                  if (buttonText == '듣기') {
                    handleListen(); // '듣기' 버튼 기능 호출
                  } else {
                    handleResponse(buttonText: buttonText); // '응답하기' 또는 '넘어가기' 버튼 처리
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

  ResultPage({required this.score});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: Container(
        color: Colors.white,
        child: Center(
          child: Text(
            '총 점수: $score',
            style: TextStyle(fontSize: 30, color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
