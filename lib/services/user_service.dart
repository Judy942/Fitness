import 'dart:convert';

import 'package:http/http.dart' as http;

import '../presentation/onboarding_screen/start_screen.dart';

class UserService {
  static const String baseUrl = 'http://192.168.95.1:8055/users/me';

  // Future<String?> getToken() async {
  //   return "YOUR_TOKEN_HERE"; // Thay bằng cách lấy token từ SharedPreferences
  // }

  Future<Map<String, dynamic>> getUserData() async {
    String? token = await getToken();
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception("Lỗi khi lấy dữ liệu người dùng");
      }
    } catch (e) {
      print("Lỗi: $e");
      return {};
    }
  }

  Future<bool> updateUserData(Map<String, String> data) async {
    String? token = await getToken();
    try {
      final response = await http.patch(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        print("Lỗi khi cập nhật: ${response.body}");
        return false;
      }
    } catch (e) {
      print("Lỗi: $e");
      return false;
    }
  }

   Future<List<dynamic>> fetchData(String path) async {
       List<dynamic> data = [];
String? token = await getToken();
print("Token: $token"); // Debugging purpose

    final response = await http.get(
      Uri.parse(path),
      headers: {'Authorization': 'Bearer $token'},
    );
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        data = responseData['data'];
        print('Data fetched successfully $data');
        return data;
      } else {
        print('Failed to load data, ${response.statusCode}');
      }
    
    return data;
   }
}
