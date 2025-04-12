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

   Future<Map<String, dynamic>> fetchDataMap(String path) async {
       Map<String, dynamic> data = {};
       String? token = await getToken();
       print("Token: $token"); // Debugging purpose

       try {
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
       } catch (e) {
         print("Lỗi: $e");
       }
    
       return data;
   }

   Future<bool> updateData(String path, Map<String, dynamic> data) async {
       String? token = await getToken();
       print("token: $token");
       print("path: $path");
       print("data: ${json.encode(data)}");
       try {
         final response = await http.patch(
           Uri.parse(path),
           headers: {
             'Authorization': 'Bearer $token',
             'Content-Type': 'application/json'
           },
           body: json.encode(data)
         );
         
         if (response.statusCode == 200) {
           print('Dữ liệu đã được cập nhật thành công');
           return true;
         } else {
           print('Cập nhật dữ liệu thất bại, ${response.statusCode}');
           return false;
         }
       } catch (e) {
         print("Lỗi khi cập nhật dữ liệu: $e");
         return false;
       }
   }

   Future<bool> postData(String path, Map<String, dynamic> data) async {
    String? token = await getToken();
    print("Token: $token"); // Debugging purpose
    print("data: ${json.encode(data)}");
    final response = await http.post(
      Uri.parse(path),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
      body: json.encode(data)
      );

    if (response.statusCode == 200) {
      print('Dữ liệu đã được tạo thành công');
      return true;
    } else {
      print('Cập nhật dữ liệu thất bại, ${response.statusCode}');
      return false;
    }
   }

   Future<bool> deleteData(String path) async {
    String? token = await getToken();
    print("Token: $token"); // Debugging purpose

    final response = await http.delete(
      Uri.parse(path),
      headers: {
        'Authorization': 'Bearer $token',

        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202 || response.statusCode == 204) {
      print('Dữ liệu đã được xóa thành công');
      return true;    
    } else {
      print('Xóa dữ liệu thất bại, ${response.statusCode}');
      return false;
    }
   }

   Future<int> getCompletedExerciseId(int workoutScheduleId, int exerciseId) async {
    String? token = await getToken();
    print("Token: $token"); // Debugging purpose

    final response = await http.get(
      Uri.parse('http://192.168.95.1:8055/items/workout_schedule_exercise?workout_schedule_id=$workoutScheduleId&exercise_id=$exerciseId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json'
      },
    );

    if (response.statusCode == 200 || response.statusCode == 201 || response.statusCode == 202 || response.statusCode == 204) { 
      final responseData = json.decode(response.body);
      return responseData['data'][0]['id'];
    } else {
      print('Failed to load data, ${response.statusCode}');
      return 0;
    }   
   }

}
