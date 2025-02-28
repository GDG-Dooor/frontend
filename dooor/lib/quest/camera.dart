import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_project_final/config/api_config.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../services/api_service.dart';

class Camera_permission extends StatefulWidget {
  final int questId;
  final String questTitle;
  final String verificationType;

  Camera_permission({
    required this.questId,
    required this.questTitle,
    required this.verificationType,
  });

  @override
  _Camera_permissionState createState() => _Camera_permissionState();
}

class _Camera_permissionState extends State<Camera_permission> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // 📌 카메라 실행 후 사진 촬영
  Future<void> _pickImage() async {
    try {
      final pickedFile = await _picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        setState(() {
          _image = File(pickedFile.path);
        });

        // 📌 촬영한 사진을 서버로 업로드
        await uploadImage(File(pickedFile.path));
      }
    } catch (e) {
      debugPrint('카메라 오류: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('카메라를 실행할 수 없습니다: $e')),
      );
    }
  }

  // 📌 서버로 사진 업로드 및 검증
  Future<void> uploadImage(File imageFile) async {
    try {
      // URL에 questId를 쿼리 파라미터로 추가
      var uri = Uri.parse('${ApiConfig.baseUrl}/quests/validate')
          .replace(queryParameters: {
        'questId': widget.questId.toString(),
      });

      // GET 메서드 사용
      var request = http.MultipartRequest('GET', uri)
        ..files.add(
          await http.MultipartFile.fromPath(
            'image',
            imageFile.path,
            contentType: MediaType('image', 'jpeg'),
          ),
        );

      // 인증 토큰 추가
      if (ApiService.authToken != null) {
        request.headers['Authorization'] = ApiService.authToken!;
      }

      setState(() {
        _isUploading = true;
      });

      var response = await request.send();

      setState(() {
        _isUploading = false;
      });

      // 응답 본문을 문자열로 변환
      String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        // 서버로부터 받은 검증 결과 확인
        bool isValidated = jsonDecode(responseBody);

        if (isValidated) {
          print("✅ 퀘스트 검증 성공!");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("퀘스트 인증 완료!")),
          );

          _completeQuest(true);
        } else {
          print("❌ 퀘스트 검증 실패");

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("퀘스트 인증에 실패했습니다. 다시 시도해주세요!")),
          );
        }
      } else {
        print("❌ 서버 요청 실패. 상태 코드: ${response.statusCode}");
        print("응답 내용: $responseBody"); // 디버깅을 위한 응답 내용 출력

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("서버 요청 실패. 다시 시도해주세요!")),
        );
      }
    } catch (e) {
      debugPrint('업로드 및 검증 오류: $e');
      setState(() {
        _isUploading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('사진 업로드 및 검증 중 오류가 발생했습니다: $e')),
      );
    }
  }

  // 📌 퀘스트 완료 후 이전 화면으로 결과 반환
  void _completeQuest(bool success) {
    Navigator.pop(context, success); // 성공 여부를 반환
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 헤더
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              color: Color(0xFF9E8976),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                  Expanded(
                    child: Text(
                      "퀘스트 인증",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // 컨텐츠
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20),
                    Center(
                      child: Container(
                        padding: EdgeInsets.all(16),
                        margin: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Color(0xFFEDE1D5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              widget.questTitle,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF816856),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              "인증 방법: 사진 촬영",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30),
                    _image == null
                        ? Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              color: Color(0xFFD1BFB0),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt,
                                    size: 60,
                                    color: Color(0xFF816856),
                                  ),
                                  SizedBox(height: 16),
                                  Text(
                                    "사진을 촬영해주세요",
                                    style: TextStyle(
                                      color: Color(0xFF816856),
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Container(
                            width: 300,
                            height: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              image: DecorationImage(
                                image: FileImage(_image!),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                    SizedBox(height: 30),
                    _isUploading
                        ? Column(
                            children: [
                              CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF816856)),
                              ),
                              SizedBox(height: 16),
                              Text("업로드 중..."),
                            ],
                          )
                        : ElevatedButton(
                            onPressed: _pickImage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF816856),
                              padding: EdgeInsets.symmetric(
                                  horizontal: 32, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.camera_alt, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  _image == null ? "카메라 열기" : "다시 촬영하기",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                    SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
