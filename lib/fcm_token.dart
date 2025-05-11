// import 'dart:convert';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:googleapis_auth/auth_io.dart';

// /// Nạp service-account JSON từ assets, request scope FCM, trả về access token
// Future<String> fetchFcmAccessToken() async {
//   // 1. Load JSON từ assets
//   final jsonString = await rootBundle.loadString('assets/service-account.json');
//   final accountCredentials = ServiceAccountCredentials.fromJson(
//     json.decode(jsonString) as Map<String, dynamic>
//   );

//   // 2. Scope cho Firebase Cloud Messaging v1
//   const scopes = <String>[
//     'https://www.googleapis.com/auth/firebase.messaging'
//   ];

//   // 3. Tạo client và lấy token
//   final client = await clientViaServiceAccount(accountCredentials, scopes);
//   final token = client.credentials.accessToken.data;

//   // 4. Đóng client khi xong
//   client.close();

//   return token;
// }
