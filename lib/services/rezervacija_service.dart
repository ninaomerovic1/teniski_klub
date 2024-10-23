// ignore_for_file: prefer_const_constructors
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Rezervacija.dart';

class RezervacijaService {
  final String baseUrl =
      'https://teniski-klub-d5797-default-rtdb.europe-west1.firebasedatabase.app/rezervacije';

  Future<void> createRezervacija(Rezervacija rezervacija) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');
    if (authToken == null) {
      throw Exception(
          'Autentifikacija nije uspešna. Molimo prijavite se ponovo.');
    }

    final response = await http.post(
      Uri.parse('$baseUrl.json?auth=$authToken'),
      body: json.encode(rezervacija),
    );

    if (response.statusCode != 200) {
      throw Exception('Greška prilikom kreiranja rezervacije.');
    }
  }

  Future<List<Rezervacija>> fetchRezervacije() async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');
    final email = prefs.getString('email');
    print("OVO JE USER ID");

    print('OVO JE TOKEN');
    print(authToken);
    if (authToken == null) {
      throw Exception(
          'Autentifikacija nije uspešna. Molimo prijavite se ponovo.');
    }

    final response = await http.get(
      Uri.parse(
          '$baseUrl.json?orderBy="korisnik"&equalTo="$email"&auth=$authToken'),
    );
    print("KODIC");
    print(response.statusCode);
    if (response.statusCode != 200) {
      throw Exception('Greška prilikom dobijanja rezervacija.');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    print(data);
    final List<Rezervacija> rezervacije = [];

    data.forEach((rezId, rezData) {
      rezervacije.add(
        Rezervacija(
          id: rezId,
          datum: rezData['datum'],
          satnica: rezData['satnica'],
          teren: rezData['teren'],
          korisnik: rezData['korisnik'], // Dodaj ovo ako je potrebno
        ),
      );
    });

    return rezervacije;
  }

  Future<void> deleteRezervacija(
      String datum, String vreme, String teren) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');

    if (authToken == null) {
      throw Exception(
          'Autentifikacija nije uspešna. Molimo prijavite se ponovo.');
    }

    // Pretraži sve rezervacije
    final response = await http.get(Uri.parse('$baseUrl.json?auth=$authToken'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      String? rezervacijaId;
      data.forEach((id, rezervacija) {
        if (rezervacija['datum'] == datum &&
            rezervacija['satnica'] == vreme &&
            rezervacija['teren'] == teren) {
          rezervacijaId = id;
        }
      });

      if (rezervacijaId != null) {
        final deleteUrl = '$baseUrl/$rezervacijaId.json?auth=$authToken';
        final deleteResponse = await http.delete(Uri.parse(deleteUrl));

        if (deleteResponse.statusCode != 200) {
          throw Exception('Greška prilikom brisanja rezervacije.');
        }
      } else {
        throw Exception('Rezervacija nije pronađena.');
      }
    } else {
      throw Exception('Greška prilikom preuzimanja rezervacija.');
    }
  }

  Future<void> updateRezervacijaTime(
    String oldTime,
    String datum,
    String terenId,
    String newTime,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');

    if (authToken == null) {
      throw Exception(
          'Autentifikacija nije uspešna. Molimo prijavite se ponovo.');
    }

    // Pretraži sve termine
    final response = await http.get(Uri.parse('$baseUrl.json?auth=$authToken'));

    if (response.statusCode == 200) {
      final reservations = jsonDecode(response.body) as Map<String, dynamic>;

      // Pronađi rezervaciju koja odgovara kriterijumima
      String? rezId;
      reservations.forEach((id, rez) {
        if (rez['datum'] == datum &&
            rez['satnica'] == oldTime &&
            rez['teren'] == terenId) {
          rezId = id;
        }
      });

      if (rezId == null) {
        throw Exception('Rezervacija nije pronađena.');
      }

      final updateUrl = '$baseUrl/$rezId.json?auth=$authToken';
      final updateResponse = await http.patch(
        Uri.parse(updateUrl),
        body: json.encode({'satnica': newTime}),
      );

      if (updateResponse.statusCode == 200) {
        print('Rezervacija uspešno ažurirana');
      } else {
        throw Exception(
            'Greška pri ažuriranju rezervacije: ${updateResponse.body}');
      }
    } else {
      throw Exception('Greška pri dobijanju rezervacija: ${response.body}');
    }
  }

  Future<List<Rezervacija>> rezervacijeFiltriranje(
      String? teren, String? datum) async {
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('authToken');
    if (authToken == null) {
      throw Exception(
          'Autentifikacija nije uspešna. Molimo prijavite se ponovo.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl.json?&auth=$authToken'),
    );

    if (response.statusCode != 200) {
      throw Exception('Greška prilikom dobijanja rezervacija.');
    }

    final Map<String, dynamic> data = json.decode(response.body);
    final List<Rezervacija> rezervacije = [];

    data.forEach((rezId, rezData) {
      if (rezData['datum'] == datum && rezData['teren'] == teren) {
        rezervacije.add(
          Rezervacija(
            id: rezId,
            datum: rezData['datum'],
            satnica: rezData['satnica'],
            teren: rezData['teren'],
            korisnik: rezData['korisnik'], 
          ),
        );
      }
      ;
    });

    return rezervacije;
  }
}
