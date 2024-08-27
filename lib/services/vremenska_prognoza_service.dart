import 'dart:convert';
import 'package:http/http.dart' as http;

class VremenskaPrognozaService {
  final String apiKey = '60b951af56f445ffb94f5183089b5de2'; // Zameni sa svojim API ključem
  final String baseUrl = 'https://api.weatherbit.io/v2.0/current';

  Future<Map<String, dynamic>> dohvatiTrenutnoVreme(
      double latitude, double longitude) async {
    final response = await http.get(
      Uri.parse('$baseUrl?lat=$latitude&lon=$longitude&key=$apiKey'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      var weather = data['data'][0];
      return {
        'temperature': weather['temp'],
        'weather_description': weather['weather']['description'],
        'humidity': weather['rh'],
        'wind_speed': weather['wind_spd'],
      };
    } else {
      throw Exception('Failed to load current weather data');
    }
  }
}
