import 'package:career_guild/auth/auth.dart';
import 'package:career_guild/auth/login_or_register.dart';
import 'package:career_guild/firebase_options.dart';
import 'package:career_guild/pages/home_page.dart';
import 'package:career_guild/pages/login_page.dart';
import 'package:career_guild/pages/profile_page.dart';
import 'package:career_guild/pages/register_page.dart';
import 'package:career_guild/pages/users_page.dart';
import 'package:career_guild/theme/dark_mode.dart';
import 'package:career_guild/theme/light_mode.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
      routes: {
        '/login_register_page': (context) => const LoginOrRegister(),
        '/home_page': (context) => HomePage(),
        '/profile_page': (context) => ProfilePage(),
        '/users_page': (context) => const UsersPage(),
      },
    );
  }
}
