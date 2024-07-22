import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:messaing/auth/auth.dart';
import 'package:messaing/firebase_options.dart';
import 'package:messaing/login_or_register.dart';
import 'package:messaing/pages/home_page.dart';
import 'package:messaing/pages/profile_page.dart';
import 'package:messaing/pages/register_page.dart';
import 'package:messaing/pages/users_page.dart';
import 'package:messaing/theme/dark_mode.dart';
import 'package:messaing/theme/light_mode.dart';
import 'pages/login_page.dart';
import 'login_or_register.dart';
void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home:const AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
      routes: {
        //list all the pages here
        '/login_register_page':(context)=> const LoginOrRegister(),
        '/home_page':(context)=>HomePage(),
        '/profile_page':(context)=>  ProfilePage(),
        '/users_page':(context)=> const UsersPage() ,

      }


    );
  }
}
