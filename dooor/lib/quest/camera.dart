import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_project_final/config/api_config.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class QuestVerificationScreen extends StatefulWidget {
  @override
  _QuestVerificationScreenState createState() =>
      _QuestVerificationScreenState();
}

class _QuestVerificationScreenState extends State<QuestVerificationScreen> {
  File? _image;
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // 📌 카메라 실행 후 사진 촬영
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      // 📌 촬영한 사진을 서버로 업로드 (questId 예제: 1)
      await uploadImage(File(pickedFile.path), 1);
    }
  }

  // 📌 서버로 사진 업로드
  Future<void> uploadImage(File imageFile, int questId) async {
    var uri = Uri.parse(
        '${ApiConfig.baseUrl}/api/quests/validate'); // 📌 업로드 API 확인 필요

    var request = http.MultipartRequest('get', uri)
      ..fields['questId'] = questId.toString() // 퀘스트 ID 추가
      ..files.add(
        await http.MultipartFile.fromPath(
          'image',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'), // ✅ MIME 타입 설정
        ),
      );

    setState(() {
      _isUploading = true;
    });

    var response = await request.send();

    setState(() {
      _isUploading = false;
    });

    if (response.statusCode == 200) {
      print("✅ 업로드 성공!");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("퀘스트 인증 완료!")),
      );

      // 📌 퀘스트 완료 처리
      _completeQuest();
    } else {
      print("❌ 업로드 실패");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("업로드 실패. 다시 시도해주세요!")),
      );
    }
  }

  // 📌 퀘스트 완료 후 다음 단계로 이동
  void _completeQuest() {
    Navigator.pop(context); // 이전 화면으로 돌아가기
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("퀘스트 인증")),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _image == null
              ? Text("손 글씨 사진을 찍어주세요.")
              : Image.file(_image!, width: 300, height: 300),
          SizedBox(height: 20),
          _isUploading
              ? CircularProgressIndicator()
              : ElevatedButton(
                  onPressed: _pickImage,
                  child: Text("📸 카메라 열기"),
                ),
        ],
      ),
    );
  }
}
