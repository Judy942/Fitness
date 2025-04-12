import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';

import '../onboarding_screen/start_screen.dart';

const storage = FlutterSecureStorage();

// Kiểm tra và tạo key/iv trong Keystore nếu chưa có
Future<Map<String, String>> getKeyAndIv() async {
  String? key = await storage.read(key: 'encryption_key');
  String? iv = await storage.read(key: 'encryption_iv');
  if (key == null || iv == null) {
    final key = encrypt.Key.fromLength(32);
    final iv = encrypt.IV.fromLength(16);
    await storage.write(key: 'encryption_key', value: key.base64);
    await storage.write(key: 'encryption_iv', value: iv.base64);
    print("đã tạo key và iv");

    return {'key': key.base64, 'iv': iv.base64};
  }
  print("đã có key và iv");
  return {'key': key, 'iv': iv};
}
// final key = encrypt.Key.fromUtf8('my 32 length key................'); // 32 chars key for AES-256
// final iv = encrypt.IV.fromLength(16); // AES sử dụng 16 byte IV

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

  Uint8List addPadding(Uint8List input) {
    int blockSize = 16; // Kích thước block của AES
    int paddingLength = blockSize - (input.length % blockSize);
    if (paddingLength == 0) {
      return input; // Không cần padding nếu đã là bội số của blockSize
    }

    Uint8List paddedInput = Uint8List(input.length + paddingLength);
    paddedInput.setAll(0, input);

    // Padding theo chuẩn PKCS7: điền paddingLength vào cuối dữ liệu
    for (int i = 0; i < paddingLength; i++) {
      paddedInput[input.length + i] = paddingLength;
    }
    print(paddingLength);
    return paddedInput;
  }

  Future<String> encryptImage(String imagePath) async {
    // Đọc hình ảnh dưới dạng byte
    File imageFile = File(imagePath);
    Uint8List imageBytes = await imageFile.readAsBytes();

    // Thêm padding vào dữ liệu hình ảnh
    print("độ dài sau khi thêm padding: ${imageBytes.length}");

    Uint8List paddedImageBytes = addPadding(imageBytes);

    final keyAndIv = await getKeyAndIv();

// Ensure that both key and iv are not null before using them
    String? encryptionKey = keyAndIv['key'];
    String? encryptionIv = keyAndIv['iv'];

    if (encryptionKey == null || encryptionIv == null) {
      // Handle the case where the key or iv is missing
      throw Exception("Key or IV is missing in storage");
    }

    final key = encrypt.Key.fromBase64(encryptionKey);
    final iv = encrypt.IV.fromBase64(encryptionIv);

    final encrypter =
        encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));

    // Mã hóa dữ liệu hình ảnh đã được padding
    final encrypted = encrypter.encryptBytes(paddedImageBytes, iv: iv);
    // Chuyển đổi dữ liệu đã mã hóa thành Base64
    String base64Encrypted = base64.encode(encrypted.bytes);
    print("độ dài sau khi mã hóa: ${encrypted.bytes.length}");
    print("Độ dài Base64 sau khi mã hóa: ${base64Encrypted.length}");

    // Lưu vào file văn bản
    String encryptedFilePath = '${imagePath}_encrypted.txt';
    File encryptedFile = File(encryptedFilePath);
    await encryptedFile.writeAsString(base64Encrypted);

    return encryptedFilePath;
  }


  Future<String> uploadFile(String filePath) async {
    String? token = await getToken();

    // Encrypt the image before uploading
    String encryptedFilePath = await encryptImage(filePath);

    // Now use the encrypted file for upload
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.95.1:8055/files'),
    );

    request.headers['Authorization'] = 'Bearer $token';

    request.files
        .add(await http.MultipartFile.fromPath('file', encryptedFilePath));

    var response = await request.send();

    if (response.statusCode == 200) {
      final responseData = await response.stream.bytesToString();
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
      Uri.parse('http://192.168.95.1:8055/items/process_tracker'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: jsonEncode({
        'image': id,
        'tracker_position_id': process,
      }),
    );
    var response = await request;
    print(response.body);
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
      appBar: AppBar(title: const Text('Camera')),
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
