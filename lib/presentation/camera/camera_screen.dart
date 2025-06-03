import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../services/user_service.dart';

const storage = FlutterSecureStorage();

// Tạo key và iv từ mật khẩu
Future<Map<String, String>> generateKeyAndIvFromPassword(String password) async {
  // Tạo hash từ mật khẩu
  final passwordBytes = utf8.encode(password);
  final hash = sha256.convert(passwordBytes);
  final hashBytes = hash.bytes;
  
  // Sử dụng 32 byte đầu tiên cho key
  final key = encrypt.Key(Uint8List.fromList(hashBytes.sublist(0, 32)));
  
  // Sử dụng 16 byte tiếp theo cho iv
  final iv = encrypt.IV(Uint8List.fromList(hashBytes.sublist(0, 16)));
  
  return {
    'key': key.base64,
    'iv': iv.base64
  };
}

// Kiểm tra và tạo key/iv trong Keystore nếu chưa có
Future<Map<String, String>> getKeyAndIv() async {
  String? key = await storage.read(key: 'encryption_key');
  String? iv = await storage.read(key: 'encryption_iv');
  
  if (key == null || iv == null ) {
    throw Exception("Key hoặc IV không tồn tại trong storage");
  }

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
  final ImagePicker _picker = ImagePicker();

  Uint8List addPadding(Uint8List input) {
    try {
      int blockSize = 16;
      int paddingLength = blockSize - (input.length % blockSize);
      if (paddingLength == 0) {
        return input;
      }

      Uint8List paddedInput = Uint8List(input.length + paddingLength);
      paddedInput.setAll(0, input);
      
      for (int i = 0; i < paddingLength; i++) {
        paddedInput[input.length + i] = paddingLength;
      }
      
      return paddedInput;
    } catch (e) {
      print('Lỗi khi thêm padding: $e');
      rethrow;
    }
  }

  Future<String> encryptImage(String imagePath) async {
    try {
      File imageFile = File(imagePath);
      Uint8List imageBytes = await imageFile.readAsBytes();
      
      Uint8List paddedImageBytes = addPadding(imageBytes);
      final keyAndIv = await getKeyAndIv();
      
      String? encryptionKey = keyAndIv['key'];
      String? encryptionIv = keyAndIv['iv'];
      
      if (encryptionKey == null || encryptionIv == null) {
        throw Exception("Key hoặc IV không tồn tại trong storage");
      }
      
      final key = encrypt.Key.fromBase64(encryptionKey);
      final iv = encrypt.IV.fromBase64(encryptionIv);
      
      // Kiểm tra độ dài IV
      if (iv.bytes.length != 16) {
        throw Exception("IV không đúng độ dài (phải là 16 bytes)");
      }
      
      final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
      final encrypted = encrypter.encryptBytes(paddedImageBytes, iv: iv);
      
      String base64Encrypted = base64.encode(encrypted.bytes);
      String encryptedFilePath = '${imagePath}_encrypted.txt';
      File encryptedFile = File(encryptedFilePath);
      await encryptedFile.writeAsString(base64Encrypted);
      
      return encryptedFilePath;
    } catch (e) {
      print('Lỗi khi mã hóa: $e');
      rethrow;
    }
  }


  Future<String> uploadFile(String filePath) async {
    String? token = await getToken();

    // Encrypt the image before uploading
    String encryptedFilePath = await encryptImage(filePath);

    // Now use the encrypted file for upload
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('http://192.168.133.100:8055/files'),
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
      Uri.parse('http://192.168.133.100:8055/items/process_tracker'),
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

  Future<void> tracker_position(String imagePath) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Chọn vị trí theo dõi'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Nhìn thẳng'),
                onTap: () {
                  addProcessTracker(imagePath, 1);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã lưu')),
                  );
                },
              ),
              ListTile(
                title: const Text('Nhìn sau'),
                onTap: () {
                  addProcessTracker(imagePath, 2);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã lưu')),
                  );
                },
              ),
              ListTile(
                title: const Text('Nhìn trái'),
                onTap: () {
                  addProcessTracker(imagePath, 3);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã lưu')),
                  );
                },
              ),
              ListTile(
                title: const Text('Nhìn phải'),
                onTap: () {
                  addProcessTracker(imagePath, 4);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã lưu')),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showCaptureDialog(String imagePath) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ảnh đã chọn'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                File(imagePath),
                height: MediaQuery.of(context).size.height * 0.6,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              const Text('Bạn có muốn sử dụng ảnh này không?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                tracker_position(imagePath);
              },
              child: const Text('Sử dụng'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Hủy'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        _showCaptureDialog(image.path);
      }
    } catch (e) {
      print('Lỗi khi chọn ảnh: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chọn ảnh'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.photo_library,
              size: 100,
              color: Colors.grey,
            ),
            const SizedBox(height: 20),
            const Text(
              'Chọn ảnh từ thư viện',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Chọn ảnh'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
