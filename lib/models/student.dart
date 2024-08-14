import 'package:intl/intl.dart';

class Student {
  String? id;
  String name;
  String email;
  String phone;
  int age;
  String gender;
  String country;
  String goal;
  DateTime startDate;
  int? todos;
  int? incompletes;
  int? meetings;
  String? profileUrl;
  String? fcmToken;

  Student(
      {this.id,
      required this.name,
      required this.email,
      required this.phone,
      required this.age,
      required this.gender,
      required this.country,
      required this.goal,
      required this.startDate,
      this.todos,
      this.incompletes,
      this.meetings,
      this.profileUrl,
      this.fcmToken});

  // Method to convert Student object to JSON format for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'gender': gender,
      'country': country,
      'goal': goal,
      'startDate': startDate.toIso8601String(),
      'todos': todos ?? 0,
      'incompletes': incompletes ?? 0,
      'meetings': meetings ?? 0,
      'profileUrl': profileUrl ?? '',
      'fcmToken': fcmToken ?? ''
    };
  }

  // Method to update fields dynamically
  void updateField(String key, dynamic value) {
    switch (key) {
      case 'todos':
        todos = value;
        break;
      case 'incompletes':
        incompletes = value;
        break;
      case 'meetings':
        meetings = value;
        break;
      case 'profileUrl':
        profileUrl = value;
        break;
      case 'country':
        country = value;
        break;
      default:
        throw Exception("Field $key does not exist in Student");
    }
  }

  // Method to create a Student object from Firestore data
  factory Student.fromJson(Map<String, dynamic> json, String id) {
    return Student(
        id: id,
        name: json['name'],
        email: json['email'],
        phone: json['phone'],
        age: json['age'],
        gender: json['gender'],
        country: json['country'],
        goal: json['goal'],
        startDate: DateTime.parse(json['startDate']),
        todos: json['todos'] ?? 0,
        incompletes: json['incompletes'] ?? 0,
        meetings: json['meetings'] ?? 0,
        profileUrl: json['profileUrl'] ?? '',
        fcmToken: json['fcmToken'] ?? '');
  }

  String get formattedstartDate =>
      DateFormat('MMMM d, yyyy \'at\' h:mm a').format(startDate);

  String get formattedDate => DateFormat('MMMM d, yyyy').format(startDate);
}
