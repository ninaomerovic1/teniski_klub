import 'package:flutter/material.dart';
import 'package:teniski_klub_projekat/services/vremenska_prognoza_service.dart';

class VremenskaPrognozaWidget extends StatefulWidget {
  final double latitude;
  final double longitude;

  VremenskaPrognozaWidget({required this.latitude, required this.longitude});

  @override
  _VremenskaPrognozaWidgetState createState() =>
      _VremenskaPrognozaWidgetState();
}

class _VremenskaPrognozaWidgetState extends State<VremenskaPrognozaWidget> {
  late Future<Map<String, dynamic>> futureTrenutnoVreme;
  late VremenskaPrognozaService vremenskaPrognozaService;

  @override
  void initState() {
    super.initState();
    vremenskaPrognozaService = VremenskaPrognozaService();
    futureTrenutnoVreme = vremenskaPrognozaService.dohvatiTrenutnoVreme(
      widget.latitude,
      widget.longitude,
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: futureTrenutnoVreme,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (!snapshot.hasData) {
          return Center(child: Text('No data available'));
        } else {
          var weatherData = snapshot.data!;
          return Container(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Temperatura: ${weatherData['temperature']}°C',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Opis: ${weatherData['weather_description']}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  'Vlažnost: ${weatherData['humidity']}%',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Brzina vetra: ${weatherData['wind_speed']} m/s',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
