import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Termin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TerminService {
  final String baseUrl = 'https://teniski-klub-d5797-default-rtdb.europe-west1.firebasedatabase.app//termini'; // Zameni sa tvojim base URL-om


  Future<bool> postojiTermin(Termin termin) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');
  final response = await http.get(
    Uri.parse('$baseUrl.json?auth=$authToken'), // Pretpostavljam da je ovo tvoj URL baze
    
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body) as Map<String, dynamic>?;
    if (data != null) {
      for (var entry in data.entries) {
        final existingTermin = Termin.fromJson(entry.value);
        if (existingTermin.datum == termin.datum &&
            existingTermin.satnica == termin.satnica &&
            existingTermin.teren == termin.teren) {
          return true; // Termin već postoji
        }
      }
    }
  } else {
    throw Exception('Greška prilikom provere termina: ${response.statusCode}');
  }
  return false; // Termin ne postoji
}


  Future<void> kreirajTermin(Termin termin, ) async {

    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');
    print("OVO JE TOKEN");
    print(authToken);

    if (authToken == null) {
      // Ako nema tokena, vrati praznu listu
      print("NEMA TOKENA");
      return null;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl.json?auth=$authToken'), // Dodaj `.json` na kraj URL-a zbog Firebase-a
        body: json.encode(termin.toMap()),
      );

      if (response.statusCode == 200) {
        print('Termin uspešno kreiran: ${response.body}');
      } else {
        print('Greška pri kreiranju termina: ${response.statusCode}');
      }
    } catch (error) {
      print('Došlo je do greške: $error');
    }
  }

  Future<void> kreirajSveTermineZaNarednaDvaMeseca(
      String datum, String teren) async {
    // Ovde možeš dodati logiku za automatsko kreiranje termina za naredna dva meseca
    // Možeš koristiti datum i teren kao polaznu tačku
    // i kreirati termine u petlji
  }
}
