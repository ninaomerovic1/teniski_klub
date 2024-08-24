import 'package:flutter/material.dart';

class Pocetna extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Bela pozadina
          image: DecorationImage(
            image: AssetImage('assets/reketi.png'), // Slika reketa
            scale: 8.0,
            repeat: ImageRepeat.repeat, // Ponavlja sliku da pokrije pozadinu
            fit: BoxFit.none,
          ),
        ),
        child: Center(
          child: Container(
            width: 300,
             // Širina belog prozora
            padding: EdgeInsets.all(16), // Razmak unutar belog prozora
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12), // Zaobljeni uglovi
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // Promena pozicije senke
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Dobrodošli',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16), // Razmak između teksta
                Text(
                  'Ovo je početna stranica vaše aplikacije za vođenje teniskog kluba. Izaberite jednu od opcija u meniju iznad kako biste nastavili.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
