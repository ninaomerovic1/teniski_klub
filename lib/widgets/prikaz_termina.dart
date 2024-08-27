// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:teniski_klub_projekat/services/termin_service.dart';

class PrikazTermina extends StatelessWidget {
  final String? id;
  final String datum;
  final String vreme;
  final String teren;
  final bool jeSlobodan;
  final VoidCallback onOtkazi;

  const PrikazTermina({
    required this.id,
    required this.datum,
    required this.vreme,
    required this.teren,
    required this.jeSlobodan,
    required this.onOtkazi,
  });

  void _obrisi() async {
    print("USAO SAM U OBRISI");
    final TerminService terminService = TerminService();
    bool uspeh = await terminService
        .obrisiTermin(id); // Pozovi funkciju za brisanje termina
    if (uspeh) {
      onOtkazi();
    } else {
      // Ako nije uspešno obrisan, obavesti korisnika
    }
  }

  void _onObrisiPressed(BuildContext context) {
    if (jeSlobodan) {
      // Ako je termin slobodan, prikaži dijalog za potvrdu brisanja
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Potvrda brisanja',
              style: TextStyle(fontSize: 18.0),
            ),
            content: Text(
              'Da li ste sigurni da želite da obrišete ovaj termin?',
              style: TextStyle(fontSize: 16.0),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Zatvori dijalog
                  // Pozovi funkciju za brisanje termina
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.orange),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                child: Text(
                  'Ne',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  _obrisi();
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.orange),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                child: Text(
                  'Da',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          );
        },
      );
    } else {
      // Ako termin nije slobodan, prikaži obaveštenje
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              'Obaveštenje',
              style: TextStyle(fontSize: 18.0),
            ),
            content: Text(
              'Morate prvo otkazati rezervaciju da biste obrisali termin!',
              style: TextStyle(fontSize: 16.0),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Zatvori dijalog
                },
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.orange),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                child: Text(
                  'U redu',
                  style: TextStyle(fontSize: 16.0),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: jeSlobodan ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: Colors.orange,
          width: 2.0,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Datum: $datum',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  'Vreme: $vreme',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                Text(
                  'Teren: $teren',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  jeSlobodan ? 'Slobodan' : 'Rezervisan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.0),
          ElevatedButton(
            onPressed: () => _onObrisiPressed(context),
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.all(Colors.orange),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              minimumSize: WidgetStateProperty.all<Size>(Size(100, 50)),
              shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
              padding: WidgetStateProperty.all<EdgeInsets>(
                EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              ),
            ),
            child: Text('Obriši'),
          ),
        ],
      ),
    );
  }
}
