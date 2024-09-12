
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../model/user.dart';
import 'api_login.dart';

class ApiServices{
  Future<List<User>> fetchUser() {
    return http
        .get(ApiUrls().API_USER_LIST)
        .then((http.Response response) {
      final String jsonBody = response.body;
      final int statusCode = response.statusCode;
      if(statusCode != 200){
        // ignore: avoid_print
        print(response.reasonPhrase);
        throw Exception("Lỗi load api");
      }
      const JsonDecoder decoder = JsonDecoder();
      final useListContainer = decoder.convert(jsonBody);
      final List userList = useListContainer['results'];
      return userList.map((contactRaw) => User.fromJson(contactRaw)).toList();
    });
  }
}