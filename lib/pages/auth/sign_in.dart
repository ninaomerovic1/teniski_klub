import 'package:flutter/material.dart';
import 'package:teniski_klub_projekat/pages/auth/auth.dart';
import '../../services/firebase_auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Size _screenSize;
  double _ballX = 0;
  double _ballY = 0;
  double _ballDX = 2;
  double _ballDY = 2;
  final double _ballSize = 50;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final FirebaseAuthService _authService = FirebaseAuthService();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 10),
      vsync: this,
    )
      ..addListener(_updateBallPosition)
      ..repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _updateBallPosition() {
    setState(() {
      _ballX += _ballDX;
      _ballY += _ballDY;

      _screenSize = MediaQuery.of(context).size;

      if (_ballX <= 0 || _ballX >= _screenSize.width - _ballSize) {
        _ballDX = -_ballDX;
      }
      if (_ballY <= 0 || _ballY >= _screenSize.height - _ballSize) {
        _ballDY = -_ballDY;
      }
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return emailRegex.hasMatch(email);
  }

  bool _isValidPassword(String password) {
    return password.length >= 6;
  }

  Future<void> _signIn() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unesite ispravan email')),
      );
      return;
    }

    if (!_isValidPassword(password)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lozinka mora imati najmanje 6 karaktera')),
      );
      return;
    }

   final credentials = await _authService.signIn(email, password);
    if (credentials != null) {
      final parts = credentials.split('|');
      final idToken = parts[0];
      final userId = parts[1];
      final userEmail = parts[2];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('authToken', idToken);
      await prefs.setString('userId', userId);
      await prefs.setString('email', userEmail);
      print("token u sign in");
      print(idToken);
      final korisnik = await _authService.fetchUserData(userId, idToken);

      if (korisnik != null) {
        await prefs.setBool('isAdmin', korisnik.isAdmin);
        print("evo me u login pageu i korisnik je");
        print(korisnik);
        Navigator.pushNamed(context, '/home');  
    }else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Neispravan email ili lozinka')),
        );
      }
  }else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Neispravan email ili lozinka')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 4, 113, 7),
      body: Stack(
        children: [
          Positioned(
            left: _ballX,
            top: _ballY,
            child: Image.asset(
              'assets/tennis-ball-bella.png',
              width: _ballSize,
              height: _ballSize,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    'Teniski Klub',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Prijavite se',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 32),
                  TextField(
                    controller: _emailController,
                    cursorColor: Colors.orange,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.orange, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.orange, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    cursorColor: Colors.orange,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      hintText: 'Lozinka',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.orange, width: 2),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.orange, width: 2),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.orange, width: 2),
                      ),
                    ),
                  ),
                  SizedBox(height: 32),
                  ElevatedButton(
                    onPressed: _signIn,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 255, 152, 0),
                      foregroundColor: Color.fromARGB(255, 255, 255, 255),
                      padding:
                          EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                    ),
                    child: Text('Prijavi se',
                        style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Ukoliko nemate nalog, ',
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        child: const Text(
                          'registrujte se',
                          style: TextStyle(
                            color: Colors.orange,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
