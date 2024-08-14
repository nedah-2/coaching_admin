import 'package:intl/intl.dart';

class Alumnus {
  String? id;
  String name;
  String email;
  String phone;
  int age;
  String gender;
  String country;
  String goal;
  String? profileUrl;

  Alumnus({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.age,
    required this.gender,
    required this.country,
    required this.goal,
    this.profileUrl,
  });

  // Method to convert Alumnus object to JSON format for Firestore
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'age': age,
      'gender': gender,
      'country': country,
      'goal': goal,
      'profileUrl': profileUrl ?? '',
    };
  }

  // Method to create an Alumnus object from Firestore data
  factory Alumnus.fromJson(Map<String, dynamic> json, String id) {
    return Alumnus(
      id: id,
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      age: json['age'],
      gender: json['gender'],
      country: json['country'],
      goal: json['goal'],
      profileUrl: json['profileUrl'] ?? '',
    );
  }
}

class Term {
  DateTime startDate;
  DateTime endDate;
  List<String> todos;
  List<String> incompleteTodos;
  List<String> meetingsAttended;
  List<String> meetingsFailedToAttend;

  Term({
    required this.startDate,
    required this.endDate,
    required this.todos,
    required this.incompleteTodos,
    required this.meetingsAttended,
    required this.meetingsFailedToAttend,
  });

  // Method to convert Term object to JSON format for Firestore
  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'todos': todos,
      'incompleteTodos': incompleteTodos,
      'meetingsAttended': meetingsAttended,
      'meetingsFailedToAttend': meetingsFailedToAttend,
    };
  }

  // Method to create a Term object from Firestore data
  factory Term.fromJson(Map<String, dynamic> json) {
    return Term(
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      todos: List<String>.from(json['todos']),
      incompleteTodos: List<String>.from(json['incompleteTodos']),
      meetingsAttended: List<String>.from(json['meetingsAttended']),
      meetingsFailedToAttend: List<String>.from(json['meetingsFailedToAttend']),
    );
  }

  String get formattedStartDate => DateFormat('MMMM d, yyyy').format(startDate);

  String get formattedEndDate => DateFormat('MMMM d, yyyy').format(endDate);
}
