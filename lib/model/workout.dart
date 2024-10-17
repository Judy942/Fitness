import 'dart:convert';

import 'package:http/http.dart' as http;

import '../presentation/onboarding_screen/start_screen.dart';

class Workout {
  final int id;
  final String name;
  final String status;
  final int time;
  final int totalExercises;
  final int totalCaloriesBurned;
  final List<Exercise> exercises;
  final List<Equipment> equipments;

  Workout({
    required this.id,
    required this.name,
    required this.status,
    required this.time,
    required this.totalExercises,
    required this.totalCaloriesBurned,
    required this.exercises,
    required this.equipments,
  });

    List<GroupedExercise> groupExercisesBySetNumber() {
    Map<int, List<Exercise>> groupedExercisesMap = {};

    for (var exercise in exercises) {
      final setNumber = exercise.setNumber ?? 0; // Nếu setNumber là null, dùng 0
      if (groupedExercisesMap.containsKey(setNumber)) {
        groupedExercisesMap[setNumber]!.add(exercise);
      } else {
        groupedExercisesMap[setNumber] = [exercise];
      }
    }
    return groupedExercisesMap.entries
        .map((entry) => GroupedExercise(
              setNumber: entry.key,
              exercises: entry.value,
            ))
        .toList()
      ..sort((a, b) => a.setNumber.compareTo(b.setNumber)); // Sắp xếp theo setNumber
  }
}

class Exercise {
  final String title;
  final String? description;
  final int? setNumber;
  final String? unit;
  final String image;
  final int caloriesBurned;
  final String? difficulty;
  final String? value;
  final int id;

  Exercise({
    required this.title,
    this.description,
    this.setNumber,
    this.unit,
    required this.image,
    required this.caloriesBurned,
    this.difficulty,
    this.value,
    required this.id,
  });
  }

class Equipment {
  final String name;
  final String code;
  final String image;

  Equipment({
    required this.name,
    required this.code,
    required this.image,
  });
   Map<String, dynamic> toMap() {
    return {
      'name': name,
      'code': code,
      'image': image,
    };
  }

  static Equipment fromMap(Map<String, dynamic> map) {
    return Equipment(
      name: map['name'],
      code: map['code'],
      image: map['image'],
    );
  }
}


Future<Workout> getWorkoutDetail(int id) async {
  String url = 'http://162.248.102.236:8055/api/workouts/$id?difficulity=EASY';
  String? token = await getToken();

  try {
    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $token'},
    );
    print('getWorkoutDetail response: ${response.statusCode}');
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final workoutData = data['data'];

      List<Exercise> exercises = (workoutData['exercises'] as List).map((exercise) {
        final exerciseId = exercise['exercise_id'];
        final exerciseDifficulties = exerciseId['exercise_difficulties'] as List<dynamic>? ?? [];
        return Exercise(
          title: exerciseId['title'] ?? 'Unknown Title', // Gán giá trị mặc định nếu null
          description: exerciseId['description'],
          setNumber: exercise['set_number'],
          unit: exercise['unit'].toString(),
          image: 'http://162.248.102.236:8055/assets/${exerciseId['image']}',
          caloriesBurned: exerciseDifficulties.isNotEmpty
              ? exerciseDifficulties[0]['calories_burn'] ?? 0 // Gán giá trị mặc định nếu null
              : 0,
          difficulty: exerciseDifficulties.isNotEmpty
              ? exerciseDifficulties[0]['difficulty_id']['code'] // Sử dụng toán tử ? để tránh lỗi
              : null,
          value: exerciseDifficulties.isNotEmpty
              ? exerciseDifficulties[0]['value'].toString() // Sử dụng toán tử ? để tránh lỗi
              : '0',
          id: exerciseId['id'] ?? 0,
        );
        
      }).toList();
      List<Equipment> equipments = (workoutData['equipments'] as List).map((equipment) {
        final equipmentId = equipment['equipment_id'];
        return Equipment(
          name: equipmentId['name'] ?? 'Unknown Equipment', // Gán giá trị mặc định nếu null
          code: equipmentId['code'] ?? 'Unknown Code', // Gán giá trị mặc định nếu null
          image: 'http://162.248.102.236:8055/assets/${equipmentId['image']}',
        );
      }).toList();
      return Workout(
        id: workoutData['id'] ?? 0, // Gán giá trị mặc định nếu null
        name: workoutData['name'] ?? 'Unknown Workout', // Gán giá trị mặc định nếu null
        status: workoutData['status'] ?? 'Unknown Status', // Gán giá trị mặc định nếu null
        time: workoutData['time'] ?? 0, // Gán giá trị mặc định nếu null
        totalExercises: workoutData['total_exercise'] ?? 0, // Gán giá trị mặc định nếu null
        totalCaloriesBurned: workoutData['total_calories_burn'] ?? 0, // Gán giá trị mặc định nếu null
        exercises: exercises,
        equipments: equipments,
      );
    } else {
      print('Error: ${response.statusCode}');
      throw Exception('Failed to load workout details');
    }
  } catch (error) {
    print('Error fetching workout details: $error');
  }

  print('getWorkoutDetail failed');
  return Workout(
    id: 0,
    name: 'Unknown Workout',
    status: 'Unknown Status',
    time: 0,
    totalExercises: 0,
    totalCaloriesBurned: 0,
    exercises: [],
    equipments: [],
  );
}

class GroupedExercise {
  final int setNumber;
  final List<Exercise> exercises;

  GroupedExercise({
    required this.setNumber,
    required this.exercises,
  });
}