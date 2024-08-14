import 'package:coaching_admin/firebase_options.dart';

import 'package:coaching_admin/provider/auth_provider.dart';
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Create an instance of StudentSearchService
  final studentSearchService = StudentSearchService();

  // Clear students database if a week has passed since the last clear
  await studentSearchService.clearStudentsWeekly();

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
