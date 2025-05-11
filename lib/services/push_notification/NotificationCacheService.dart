import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationCacheService {
  static const _keyWorkoutMap = 'workout_notification_ids';
  static const _keyMealMap = 'meal_notification_ids';

  // Lưu notification ID theo lịch ID
  static Future<void> saveWorkoutNotificationId(String scheduleId, int notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await _getMap(_keyWorkoutMap);
    map[scheduleId] = notificationId;
    await prefs.setString(_keyWorkoutMap, jsonEncode(map));
  }

  static Future<void> saveMealNotificationId(String mealId, int notificationId) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await _getMap(_keyMealMap);
    map[mealId] = notificationId;
    await prefs.setString(_keyMealMap, jsonEncode(map));
  }

  // Lấy notification ID theo lịch ID
  static Future<int?> getNotificationId(String scheduleId, {bool isWorkout = true}) async {
    final map = await _getMap(isWorkout ? _keyWorkoutMap : _keyMealMap);
    return map[scheduleId];
  }

  // Xóa notification ID khi xóa hoặc hoàn thành
  static Future<void> removeNotificationId(String scheduleId, {bool isWorkout = true}) async {
    final prefs = await SharedPreferences.getInstance();
    final map = await _getMap(isWorkout ? _keyWorkoutMap : _keyMealMap);
    map.remove(scheduleId);
    await prefs.setString(isWorkout ? _keyWorkoutMap : _keyMealMap, jsonEncode(map));
  }

  static Future<Map<String, dynamic>> _getMap(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(key);
    if (jsonString == null) return {};
    return Map<String, dynamic>.from(jsonDecode(jsonString));
  }
}
