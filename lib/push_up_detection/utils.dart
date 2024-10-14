import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/services.dart';
import 'package:flutter_application_fitness/push_up_detection/push_up_model.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

Future<String> getAssetPath(String asset) async {
  final path = await getLocalPath(asset);
  await Directory(dirname(path)).create(recursive: true);
  final file = File(path);
  if (!await file.exists()) {
    final byteData = await rootBundle.load(asset);
    await file.writeAsBytes(byteData.buffer
        .asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));
  }
  return file.path;
}

Future<String> getLocalPath(String path) async {
  return '${(await getApplicationSupportDirectory()).path}/$path';
}

double angle(PoseLandmark firstLandmark, PoseLandmark midLandmark, PoseLandmark lastLandmark) {
  final radians =
      math.atan2(lastLandmark.y - midLandmark.y, lastLandmark.x - midLandmark.x) - math.atan2(firstLandmark.y - midLandmark.y, firstLandmark.x - midLandmark.x);
  double degrees = radians * (180 / math.pi);
  degrees = degrees.abs();
  if (degrees > 180) {
    degrees = 360 - degrees;
  }
  return degrees;
}

PushUpState? isPushUp(double angleElbow, PushUpState current){
  final umbraElbow = 60.0;
  final umbraElbowExt = 160.0;
  if(current == PushUpState.neutral && angleElbow > umbraElbowExt && angleElbow < 180){
    return PushUpState.init;
  }else if(current == PushUpState.init && angleElbow < umbraElbow && angleElbow > 40){
    return PushUpState.complete;
  }
}