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
  final key = encrypt.Key.fromUtf8(hashBytes.sublist(0, 32).map((e) => String.fromCharCode(e)).join());
  
  // Sử dụng 16 byte tiếp theo cho iv
  final iv = encrypt.IV.fromUtf8(hashBytes.sublist(32, 48).map((e) => String.fromCharCode(e)).join());
  
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
      Uri.parse('http://192.168.1.6:8055/files'),
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
      Uri.parse('http://192.168.1.6:8055/items/process_tracker'),
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
          title: const Text('Choose your tracker position'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text('Front Facing'),
                onTap: () {
                  addProcessTracker(imagePath, 1);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved')),
                  );
                },
              ),
              ListTile(
                title: const Text('Back Facing'),
                onTap: () {
                  addProcessTracker(imagePath, 2);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved')),
                  );
                },
              ),
              ListTile(
                title: const Text('Left Facing'),
                onTap: () {
                  addProcessTracker(imagePath, 3);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Saved')),
                  );
                },
              ),
              ListTile(
                title: const Text('Right Facing'),
                onTap: () {
                  addProcessTracker(imagePath, 4);
                  Navigator.of(context).pop();
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

  Future<void> _showCaptureDialog(String imagePath) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Selected Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.file(
                File(imagePath),
                height: MediaQuery.of(context).size.height * 0.6,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 10),
              const Text('Do you want to use this image?'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                tracker_position(imagePath);
              },
              child: const Text('Use'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
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
      print('Error picking image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Image'),
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
              'Select an image from your gallery',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose Image'),
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
