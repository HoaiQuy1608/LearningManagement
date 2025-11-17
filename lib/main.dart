import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learningmanagement/firebase_options.dart';
import 'package:learningmanagement/models/user_model.dart';
import 'package:learningmanagement/screens/Admin_screens/admin_home.dart';
import 'package:learningmanagement/screens/Admin_screens/admin_main_screen.dart';
import 'package:learningmanagement/screens/authentication/login_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:learningmanagement/screens/common/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(
      authProvider.select((state) => state.isAuthenticated),
    );

    final dummyUsers = [
      UserModel(
        uid: '1',
        email: 'user1@gmail.com',
        role: UserRole.sinhVien,
        displayName: 'Nguyễn Văn A',
        isActive: true,
        isEmailVerified: true,
        createdAt: DateTime.now(),
      ),
      UserModel(
        uid: '2',
        email: 'teacher1@gmail.com',
        role: UserRole.giangVien,
        displayName: 'Trần Thị B',
        isActive: true,
        isEmailVerified: false,
        createdAt: DateTime.now(),
      ),
    ];
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
      home:  AdminMainScreen(users:dummyUsers),//isAuthenticated ? const HomeScreen() : const LoginScreen(),
    );
  }
}
