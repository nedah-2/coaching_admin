import 'package:coaching_admin/firebase_options.dart';

import 'package:coaching_admin/provider/auth_provider.dart';
import 'package:coaching_admin/provider/contact_provider.dart';
import 'package:coaching_admin/provider/meeting_dates_provider.dart';
import 'package:coaching_admin/provider/meeting_provider.dart';
import 'package:coaching_admin/provider/review_provider.dart';
import 'package:coaching_admin/provider/student_provider.dart';
import 'package:coaching_admin/provider/student_search_provider.dart';
import 'package:coaching_admin/provider/tab_provider.dart';
import 'package:coaching_admin/provider/task_provider.dart';
import 'package:coaching_admin/screen/authentication/authentication.dart';
import 'package:coaching_admin/services/search_service.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coaching_admin/models/student.dart';

Future<void> addSampleStudents() async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference usersCollection = firestore.collection('users');

  final List<Student> students = [
    Student(
      id: '',
      name: 'Alice Smith',
      email: 'alice@example.com',
      phone: '123-456-7890',
      age: 20,
      gender: 'Female',
      country: 'USA',
      goal: 'Become a developer',
      startDate: DateTime(2023, 8, 15), // Example date
    ),
    Student(
      id: '',
      name: 'Bob Johnson',
      email: 'bob@example.com',
      phone: '987-654-3210',
      age: 22,
      gender: 'Male',
      country: 'UK',
      goal: 'Start a business',
      startDate: DateTime(2023, 8, 16), // Example date
    ),
    Student(
      id: '',
      name: 'Carol White',
      email: 'carol@example.com',
      phone: '456-789-0123',
      age: 19,
      gender: 'Female',
      country: 'Canada',
      goal: 'Study abroad',
      startDate: DateTime(2023, 8, 17), // Example date
    ),
    Student(
      id: '',
      name: 'David Brown',
      email: 'david@example.com',
      phone: '321-654-9870',
      age: 21,
      gender: 'Male',
      country: 'Australia',
      goal: 'Learn a new language',
      startDate: DateTime(2023, 8, 18), // Example date
    ),
    Student(
      id: '',
      name: 'Eva Green',
      email: 'eva@example.com',
      phone: '789-012-3456',
      age: 23,
      gender: 'Female',
      country: 'Germany',
      goal: 'Get a job in tech',
      startDate: DateTime(2023, 8, 19), // Example date
    ),
    Student(
      id: '',
      name: 'Frank Black',
      email: 'frank@example.com',
      phone: '012-345-6789',
      age: 24,
      gender: 'Male',
      country: 'France',
      goal: 'Travel the world',
      startDate: DateTime(2023, 8, 20), // Example date
    ),
    Student(
      id: '',
      name: 'Grace Wilson',
      email: 'grace@example.com',
      phone: '567-890-1234',
      age: 20,
      gender: 'Female',
      country: 'Italy',
      goal: 'Start a blog',
      startDate: DateTime(2023, 8, 21), // Example date
    ),
    Student(
      id: '',
      name: 'Henry Adams',
      email: 'henry@example.com',
      phone: '678-901-2345',
      age: 22,
      gender: 'Male',
      country: 'Spain',
      goal: 'Join a startup',
      startDate: DateTime(2023, 8, 22), // Example date
    ),
    Student(
      id: '',
      name: 'Ivy Lewis',
      email: 'ivy@example.com',
      phone: '234-567-8901',
      age: 21,
      gender: 'Female',
      country: 'Netherlands',
      goal: 'Become a designer',
      startDate: DateTime(2023, 8, 23), // Example date
    ),
    Student(
      id: '',
      name: 'Jack Turner',
      email: 'jack@example.com',
      phone: '890-123-4567',
      age: 25,
      gender: 'Male',
      country: 'Brazil',
      goal: 'Study finance',
      startDate: DateTime(2023, 8, 24), // Example date
    ),
  ];

  WriteBatch batch = firestore.batch();

  for (Student student in students) {
    DocumentReference docRef = usersCollection.doc();
    student.id = docRef.id; // Set the ID for the student object
    batch.set(docRef, student.toJson());
  }

  try {
    await batch.commit();
    print('Students added successfully');
  } catch (e) {
    print('Error adding students: $e');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Create an instance of StudentSearchService
  final studentSearchService = StudentSearchService();

  // Clear students database if a week has passed since the last clear
  await studentSearchService.clearStudentsWeekly();

 // await addSampleStudents();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TabIndexProvider()),
        ChangeNotifierProvider(create: (_) => AuthManager()),
        ChangeNotifierProvider(create: (_) => ContactProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => MeetingProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => MeetingDatesProvider()),
        ChangeNotifierProvider(create: (_) => StudentSearchProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        // debugShowMaterialGrid: true,
        title: 'Coaching Admin Dashboard',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const AuthenticationScreen(),
      ),
    );
  }
}
