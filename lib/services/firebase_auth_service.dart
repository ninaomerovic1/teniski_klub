import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:teniski_klub_projekat/models/Korisnik.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseAuthService {
  final String _apiKey = 'AIzaSyCrS_XP98mXpqPmcc5JayE1evL1F18T7S4';
  final String _baseUrl = 'https://identitytoolkit.googleapis.com/v1/accounts';
  final String _userDataUrl =
      'https://teniski-klub-d5797-default-rtdb.europe-west1.firebasedatabase.app';

  Future<String?> signIn(String email, String password) async {
    print("usao sam u signin u authu");
    print(email);
    print(password);

    final response = await http.post(
      Uri.parse('$_baseUrl:signInWithPassword?key=$_apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );
    print("STATUSNI KOD:");
    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      print(response.body);
      final token = data['idToken'];
      final userId = data['localId'];
      final email = data['email'];
      print("Token");
      print(token);
      print(userId);
      return '$token|$userId|$email';
    } else {
      // Obrađuj greške
      return null;
    }
  }

  Future<KorisnikModel?> fetchUserData(String userId, String idToken) async {
    print("Usao sam u fetch");
    print(userId);

    final response = await http.get(
      Uri.parse('$_userDataUrl/korisnici/${userId}.json?auth=$idToken'),
    );
    print("stastun");
    print(response.statusCode);
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);


      if (data != null) {
        print("vracam korisnicki model ");
        print(KorisnikModel.fromJson(data, userId));
        return KorisnikModel.fromJson(data, userId);
      }
    }
    return null;
  }

  Future<String?> registerUser(String email, String password) async {
  final url = '$_baseUrl:signUp?key=$_apiKey';
  final response = await http.post(
    Uri.parse(url),
    body: json.encode({
      'email': email,
      'password': password,
      'returnSecureToken': true,
    }),
  );

  final responseData = json.decode(response.body);

  if (response.statusCode == 200) {
    final idToken = responseData['idToken'];
    final userId = responseData['localId'];
    print("u reg");
    print(userId);
    return '$idToken|$userId';
  } else {
    final error = responseData['error']['message'];
    if (error == 'EMAIL_EXISTS') {
      throw Exception('Email already in use.');
    } else {
      throw Exception('Registration failed: $error');
    }
  }
}


  Future<void> saveUserToDatabase(String userId, String idToken, String email) async {
    final response = await http.put(
      Uri.parse('$_userDataUrl/korisnici/$userId.json?auth=$idToken'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'isAdmin': false,
      }),
    );
    print("OVO JE ID USERA");
    print(userId);
    if (response.statusCode != 200) {
      throw Exception('Failed to save user to database');
    }
  }

  Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId'); // 'userId' je ključ pod kojim se čuva ID korisnika
  }


}
