// ignore_for_file: prefer_const_constructors
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:teniski_klub_projekat/pages/auth/auth.dart';
import 'package:teniski_klub_projekat/pages/auth/sign_in.dart';
import 'package:teniski_klub_projekat/pages/home/home.dart';
import 'package:teniski_klub_projekat/pages/wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teniski Klub',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.white, // Pozadina aplikacije bela
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // Pozadina AppBar bela
          elevation: 0, // Uklanja senku
          iconTheme: IconThemeData(
              color: Color.fromARGB(
                  255, 4, 113, 7)), // Ikone u AppBar-u zelene boje
        ),
        textTheme: TextTheme(
            /*titleLarge: TextStyle(color: Colors.white), 
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white), 
          bodyMedium: TextStyle(color: Colors.white), 
          bodySmall: TextStyle(color: Colors.white), 
          // Add more text styles if needed*/
            ),
      ),
      home: Wrapper(),
      routes: {
        '/home': (context) => Home(),  // Registrovanje rute za Home
        // Dodaj ovde druge rute ako ih imaš
        '/register': (context) => Authenticate(),
        '/signin': (context) => LoginPage(),
      },
    );
  }
}
