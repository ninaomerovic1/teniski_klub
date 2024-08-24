import 'package:flutter/material.dart';
import 'package:teniski_klub_projekat/widgets/prikaz_rezervacije.dart';
// Importuj PrikazRezervacije

class PregledTermina extends StatelessWidget {
  final List<Map<String, String>> rezervacije = [
    {'datum': '20.08.2024', 'vreme': '09:00', 'teren': 'Teren 1'},
    {'datum': '20.08.2024', 'vreme': '10:00', 'teren': 'Teren 2'},
    {'datum': '21.08.2024', 'vreme': '11:00', 'teren': 'Teren 3'},
    // Dodaj više rezervacija po potrebi
  ];

  void _onEdit(String datum, String vreme, String teren) {
    // Akcija za izmenu rezervacije
    print('Izmeni: $datum $vreme $teren');
  }

  void _onCancel(String datum, String vreme, String teren) {
    // Akcija za otkazivanje rezervacije
    print('Otkazi: $datum $vreme $teren');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pregled termina'),
        backgroundColor: Color.fromARGB(255, 4, 113, 7),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          image: DecorationImage(
            image: AssetImage('assets/reketi.png'),
            scale: 8.0,
            repeat: ImageRepeat.repeat,
            fit: BoxFit.none,
          ),
        ),
        child: ListView.builder(
          padding: EdgeInsets.all(16.0),
          itemCount: rezervacije.length,
          itemBuilder: (context, index) {
            final rezervacija = rezervacije[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: PrikazRezervacije(
                datum: rezervacija['datum']!,
                vreme: rezervacija['vreme']!,
                teren: rezervacija['teren']!,
                onEdit: () => _onEdit(rezervacija['datum']!,
                    rezervacija['vreme']!, rezervacija['teren']!),
                onCancel: () => _onCancel(rezervacija['datum']!,
                    rezervacija['vreme']!, rezervacija['teren']!),
              ),
            );
          },
        ),
      ),
    );
  }
}
