import 'package:flutter/material.dart';
import 'package:teniski_klub_projekat/pages/auth/auth.dart';
import 'package:teniski_klub_projekat/pages/auth/sign_in.dart';
import 'package:teniski_klub_projekat/pages/home/home.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: LoginPage(),
      ),
    );
  }
}
