import 'dart:convert';
import 'dart:typed_data';

import 'package:encrypt/encrypt.dart' as encrypt;
import 'package:http/http.dart' as http;

import '../presentation/camera/camera_screen.dart';
import 'user_service.dart';

class ImageService {
  // static Future<Uint8List> decryptAndSaveImageFromTextFile(String filePath, String fileName) async {
  //   print("filePath: $filePath");
  //   final fileUrl = 'http://192.168.102.186:8055/assets/$filePath';
  //   String fileContent = await fetchFileContent(fileUrl);
  //   try {
  //     if (fileContent.isNotEmpty) {
  //       final decryptedBytes = await decryptImageFromBase64(fileContent);
  //       if (decryptedBytes.isEmpty) {
  //         throw Exception("Giải mã thất bại: Dữ liệu sau khi giải mã rỗng.");
  //       }
  //       return decryptedBytes;
  //     } else {
  //       throw Exception("File không tồn tại tại đường dẫn: $filePath");
  //     }
  //   } catch (e) {
  //     print("Lỗi khi giải mã hoặc lưu ảnh: $e");
  //     rethrow;
  //   }
  // }

  
  static Future<Uint8List> decryptAndSaveImageFromTextFile(
      String filePath, String fileName) async {
    final fileUrl = 'http://192.168.102.186:8055/assets/$filePath';
    String fileContent = await fetchFileContent(fileUrl);
    try {
      // Kiểm tra xem file có tồn tại không
      if (fileContent.isNotEmpty) {
        // Giải mã Base64 từ nội dung file
        final decryptedBytes = await decryptImageFromBase64(fileContent);
        print("giải mã thành công!!!!");
        if (decryptedBytes.isEmpty) {
          throw Exception("Giải mã thất bại: Dữ liệu sau khi giải mã rỗng.");
        }
        return decryptedBytes;
        // Lưu ảnh vào tệp
        // return await saveImageToFile(decryptedBytes, fileName);
      } else {
        throw Exception("File không tồn tại tại đường dẫn: $filePath");
      }
    } catch (e) {
      print("Lỗi khi giải mã hoặc lưu ảnh: $e");
      rethrow;
    }
  }


  static Uint8List removePadding(Uint8List input) {
    int paddingLength = input.last;
    return input.sublist(0, input.length - paddingLength);
  }

  static Future<Uint8List> decryptImageFromBase64(String encryptedBase64) async {
    final encryptedBytes = base64.decode(encryptedBase64);
    final keyAndIv = await getKeyAndIv();

    String? encryptionKey = keyAndIv['key'];
    String? encryptionIv = keyAndIv['iv'];

    if (encryptionKey == null || encryptionIv == null) {
      throw Exception("Key hoặc IV không tồn tại trong storage");
    }

    final key = encrypt.Key.fromBase64(encryptionKey);
    final iv = encrypt.IV.fromBase64(encryptionIv);

    final encrypter = encrypt.Encrypter(encrypt.AES(key, mode: encrypt.AESMode.cbc));
    final decryptedBytes = encrypter.decryptBytes(encrypt.Encrypted(encryptedBytes), iv: iv);

    return removePadding(Uint8List.fromList(decryptedBytes));
  }

  static Future<String> fetchFileContent(String url) async {
    String? token = await getToken();
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );
      if (response.statusCode == 200) {
        return response.body;
      }
    } catch (e) {
      print("Lỗi khi tải nội dung file: $e");
    }
    return '';
  }
} 