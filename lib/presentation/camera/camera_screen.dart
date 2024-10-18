import 'dart:convert';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import '../onboarding_screen/start_screen.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  List<CameraDescription> cameras = [];
  CameraDescription? selectedCamera;

  @override
  void initState() {
    super.initState();
    initializeCamera();
  }

  // Future<String> uploadFile(String filePath) async {
  //   String? token = await getToken();
  //   var request = http.post(
  //     // Uri.parse('http://162.248.102.236:8055/$filePath'),
  //     Uri.parse('http://162.248.102.236:8055/files'),
  //     headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'multipart/form-data' },
  //     body: {
  //       'file':                 File(filePath),

  //     },
  //   );
  //   var response = await request;
  //   print(response.body);
  //   return jsonDecode(response.body)['data']['id'];
  // }

  Future<String> uploadFile(String filePath) async {
  String? token = await getToken();

  // Tạo MultipartRequest
  var request = http.MultipartRequest(
    'POST',
    Uri.parse('http://162.248.102.236:8055/files'), // Đường dẫn đúng để tải lên
  );

  // Thêm header Authorization
  request.headers['Authorization'] = 'Bearer $token';

  // Thêm tệp vào request
  request.files.add(await http.MultipartFile.fromPath(
    'file', // Tên trường mà máy chủ mong đợi
    filePath,
  ));

  // Gửi request
  var response = await request.send();

  // Kiểm tra kết quả
  if (response.statusCode == 200) {
    // Đọc dữ liệu phản hồi
    final responseData = await response.stream.bytesToString();
    print(responseData); // In ra phản hồi

    // Trả về ID từ dữ liệu phản hồi
    return jsonDecode(responseData)['data']['id'];
  } else {
    throw Exception('Upload failed with status: ${response.statusCode}');
  }
}

  Future<void> addProcessTracker(String filePath, int process) async {
    String? token = await getToken();
    String? id = await uploadFile(filePath);
    print(id);
    var request = http.post(
      Uri.parse('http://162.248.102.236:8055/items/process_tracker'),
      headers: { 'Authorization': 'Bearer $token', 'Content-Type': 'application/json' },
      body: jsonEncode({
        'image': id,
        'tracker_position_id': process,
      }),
    );
    var response = await request;
    print(response.body);

    if (response.statusCode == 200) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Tracker position added!')),
      // );
    } else {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   const SnackBar(content: Text('Failed to add tracker position!')),
      // );
    }


    
  }

  Future<void> initializeCamera() async {
    await Permission.camera.request();
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('No cameras available', 'No camera was found.');
      }
      selectedCamera = cameras.first; // Chọn camera đầu tiên mặc định

      _controller = CameraController(cameras[0], ResolutionPreset.high);
      _initializeControllerFuture = _controller.initialize();
      setState(() {});
    } catch (e) {
      print(e);
    }
  }

  Future<void> switchCamera() async {
    if (selectedCamera == cameras[0]) {
      selectedCamera = cameras[1]; // Chọn camera trước
    } else {
      selectedCamera = cameras[0]; // Chọn camera sau
    }
    _controller.dispose();
    _controller = CameraController(selectedCamera!, ResolutionPreset.high);
    _initializeControllerFuture = _controller.initialize();
    setState(() {});
  }

   Future<void> tracker_position(String imagePath) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Choose your tracker position'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Front Facing'),
                onTap: () {
                  addProcessTracker(imagePath, 1);
                  Navigator.of(context).pop(); // Đóng hộp thoại
                                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved')),
                );
                },
              ),
              ListTile(
                title: const Text('Back Facing'),
                onTap: () {
                  addProcessTracker(imagePath, 2);
                  Navigator.of(context).pop(); // Đóng hộp thoại
                                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved')),
                );
                },
              ),
              ListTile(
                title: const Text('Left Facing'),
                onTap: () {
                  addProcessTracker(imagePath, 3);
                  Navigator.of(context).pop(); // Đóng hộp thoại
                                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved')),
                );
                },
              ),

              ListTile(
                title: const Text('Right Facing'),
                onTap: () {
                  addProcessTracker(imagePath, 4);
                  Navigator.of(context).pop(); // Đóng hộp thoại
                                  ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Saved')),
                );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _saveImage(String imagePath, String bodyPart) async {
    final result = await ImageGallerySaver.saveFile(imagePath);
    // ScaffoldMessenger.of(context).showSnackBar(
    //   SnackBar(content: Text('Ảnh đã được lưu với bộ phận: $bodyPart!')),
    // );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showCaptureDialog(String imagePath) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Capture'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                File(imagePath),
                height: MediaQuery.of(context).size.height * 0.6,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              const Text('Are you sure you want to save this image?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final result = await ImageGallerySaver.saveFile(imagePath);
                Navigator.of(context).pop(); // Đóng hộp thoại
                Navigator.of(context).pop(); // Đóng hộp thoại
                tracker_position(imagePath);
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng hộp thoại
              },
              child: const Text('Try Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Camera'), actions: [
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: switchCamera,
          ),
        ],),
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return CameraPreview(_controller);
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            await _initializeControllerFuture;
            final image = await _controller.takePicture();
            _showCaptureDialog(image.path);
          } catch (e) {
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}
