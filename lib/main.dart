import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learningmanagement/firebase_options.dart';
import 'package:learningmanagement/screens/authentication/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quản lý Học tập',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.blue,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
