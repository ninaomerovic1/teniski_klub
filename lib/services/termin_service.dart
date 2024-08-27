// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/Termin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TerminService {
  final String baseUrl =
      'https://teniski-klub-d5797-default-rtdb.europe-west1.firebasedatabase.app//termini'; // Zameni sa tvojim base URL-om

  Future<bool> postojiTermin(Termin termin) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');
    final response = await http.get(
      Uri.parse(
          '$baseUrl.json?auth=$authToken'), // Pretpostavljam da je ovo tvoj URL baze
    );

    if (response.statusCode == 200) {
      print("OVO JE ODG: ");
      print(response.body);
      if (response.contentLength == 2) {
        print("USAO SAM U IF");
        return false; // Ako je odgovor prazan, termin ne postoji
      }
      final data = json.decode(response.body) as Map<String, dynamic>?;
      if (data != null) {
        for (var entry in data.entries) {
          final existingTermin = Termin.fromJson(entry.value, '');
          if (existingTermin.datum == termin.datum &&
              existingTermin.satnica == termin.satnica &&
              existingTermin.teren == termin.teren) {
            return true; // Termin već postoji
          }
        }
      }
    } else {
      throw Exception(
          'Greška prilikom provere termina: ${response.statusCode}');
    }
    return false; // Termin ne postoji
  }

  Future<void> kreirajTermin(
    Termin termin,
  ) async {
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
        Uri.parse(
            '$baseUrl.json?auth=$authToken'), // Dodaj `.json` na kraj URL-a zbog Firebase-a
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

  Future<Map<String, dynamic>> fetchTermini(String date, String courtId) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');
    if (authToken == null) {
      // Ako nema tokena, vrati praznu listu
      throw Exception(
          'Autentifikacija nije uspešna. Molimo prijavite se ponovo.');
    }
    final response = await http.get(
      Uri.parse(
          '$baseUrl.json?orderBy="datum"&equalTo="$date"&auth=$authToken'),
    );

    if (response.statusCode == 200) {
      print("STATUS JE 200");
      print(response.body);
      final Map<String, dynamic> data = json.decode(response.body);
      final List<Map<String, dynamic>> terminiSaId = data.entries
          .where(
              (entry) => entry.value['teren'] == courtId) // Filtriraj po terenu
          .map((entry) =>
              {'id': entry.key, ...entry.value as Map<String, dynamic>})
          .toList();
      print("OVO VARCAM");
      print(terminiSaId);
      return {
        'termini': terminiSaId,
      };
    } else {
      throw Exception('Greška prilikom dobijanja termina.');
    }
  }

  Future<void> updateTerminStatus(
      String datum, String satnica, String teren, bool status) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');

    if (authToken == null) {
      throw Exception(
          'Autentifikacija nije uspešna. Molimo prijavite se ponovo.');
    }

    // Pretraži sve termine
    final response = await http.get(Uri.parse('$baseUrl.json?auth=$authToken'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      // Pronađi odgovarajući termin
      String? terminId;
      data.forEach((id, termin) {
        if (termin['datum'] == datum &&
            termin['satnica'] == satnica &&
            termin['teren'] == teren) {
          terminId = id;
        }
      });

      if (terminId != null) {
        // Ako je termin pronađen, ažuriraj njegov status
        final updateUrl = '$baseUrl/$terminId.json?auth=$authToken';
        final updateResponse = await http.patch(
          Uri.parse(updateUrl),
          body: json.encode({'isSlobodan': status}),
        );

        if (updateResponse.statusCode != 200) {
          throw Exception('Greška prilikom ažuriranja statusa termina.');
        }
      } else {
        throw Exception('Termin nije pronađen.');
      }
    } else {
      throw Exception('Greška prilikom preuzimanja termina.');
    }
  }

  Future<bool> obrisiTermin(String? id) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');

    if (authToken == null) {
      throw Exception(
          'Autentifikacija nije uspešna. Molimo prijavite se ponovo.');
    }
    print("OVO JE ID");
    print(id);
    final url = Uri.parse(
        '$baseUrl/$id.json?auth=$authToken'); // URL za brisanje termina

    try {
      final response = await http.delete(url);

      if (response.statusCode == 200) {
        print("OBRISAO SAM"); // Ako je status kod 200 OK, uspešno je obrisan
        return true;
      } else {
        // Ako status kod nije 200, nešto je pošlo po zlu
        print('Greška prilikom brisanja termina: ${response.body}');
        return false;
      }
    } catch (e) {
      // Ako dođe do greške u komunikaciji
      print('Greška: $e');
      return false;
    }
  }
}
