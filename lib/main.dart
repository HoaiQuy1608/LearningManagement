import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:learningmanagement/firebase_options.dart';
import 'package:learningmanagement/screens/Admin_screens/admin_main_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learningmanagement/providers/auth_provider.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:learningmanagement/screens/authentication/login_screen.dart';
import 'package:learningmanagement/screens/forum_screens/forum_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'dart:io' show Platform;

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
  const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
  const initSettings = InitializationSettings(android: androidSettings);
  await notificationsPlugin.initialize(initSettings);
  if (Platform.isAndroid) {
    final androidInfor = await DeviceInfoPlugin().androidInfo;
    if (androidInfor.version.sdkInt >= 33) {
      await Permission.notification.request();
    }
  }
  if (Platform.isAndroid) {
    final androidPlugin = notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.requestExactAlarmsPermission();
    }
  }
  runApp(ProviderScope(child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isAuthenticated = ref.watch(
      authProvider.select((state) => state.isAuthenticated),
    );
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
      home: isAuthenticated ? ForumScreen(): const LoginScreen(),
    );
  }
}
