import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Teren.dart'; // Importuj model Teren
import 'package:shared_preferences/shared_preferences.dart';

class TereniService {
  final String baseUrl =
      "https://teniski-klub-d5797-default-rtdb.europe-west1.firebasedatabase.app//tereni";

  Future<List<Teren>> getTereni() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');
    print("OVO JE TOKEN");
    print(authToken);

    if (authToken == null) {
      // Ako nema tokena, vrati praznu listu
      print("NEMA TOKENA");
      return [];
    }

    final response = await http.get(
      Uri.parse("$baseUrl.json?auth=$authToken"),
      headers: {
        'Authorization': 'Bearer $authToken',
      },
    );

    if (response.statusCode == 200) {
      print("USAO U KOD 200");
      Map<String, dynamic> data = json.decode(response.body);
      print("DATA");
      print(data);
      return data.entries.map((entry) {
        print("OVAJ FORMAT VRACAM");
        print(Teren.fromJson(entry.value, entry.key));
        return Teren.fromJson(entry.value, entry.key);
      }).toList();
    } else if (response.statusCode == 401) {
      // U slučaju neautorizovanog pristupa, obradi grešku ili traži novu autentifikaciju
      print("Unauthorized access. Please check your token.");
      return [];
    } else {
      // U slučaju drugih grešaka, vrati praznu listu
      print("Error: ${response.statusCode}");
      return [];
    }
  }
}