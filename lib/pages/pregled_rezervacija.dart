import 'package:flutter/material.dart';
import 'package:teniski_klub_projekat/models/Rezervacija.dart';
import 'package:teniski_klub_projekat/widgets/prikaz_rezervacije.dart';
import 'package:teniski_klub_projekat/services/rezervacija_service.dart';

class PregledRezervacija extends StatefulWidget {
  @override
  _PregledRezervacijaState createState() => _PregledRezervacijaState();
}

class _PregledRezervacijaState extends State<PregledRezervacija> {
  late Future<List<Rezervacija>> _rezervacijeFuture;
  final RezervacijaService _rezervacijaService = RezervacijaService();

  @override
  void initState() {
    super.initState();
    _rezervacijeFuture = _rezervacijaService.fetchRezervacije();
  }

  void _refreshData() {
    setState(() {
      _rezervacijeFuture = _rezervacijaService.fetchRezervacije();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: FutureBuilder<List<Rezervacija>>(
          future: _rezervacijeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Došlo je do greške: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                child: Container(
                  padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                    border: Border.all(color: Colors.grey, width: 1.0),
                  ),
                  child: Text(
                    'Nema rezervacija',
                    style: TextStyle(fontSize: 18.0, color: Colors.black),
                  ),
                ),
              );
            }

            final rezervacije = snapshot.data!;

            return Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 20.0),
                  padding: EdgeInsets.all(8.0),
                  constraints: BoxConstraints(
                    maxWidth: 400.0,
                    minHeight: 50.0,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(80.0),
                    border: Border.all(
                      color: Color(0xFFFF914D), // Narandžasti border
                      width: 2.0,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    'Pregled Rezervacija',
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.black,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.all(16.0),
                    itemCount: rezervacije.length,
                    itemBuilder: (context, index) {
                      final rezervacija = rezervacije[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: PrikazRezervacije(
                          datum: rezervacija.datum,
                          vreme: rezervacija.satnica,
                          teren: rezervacija.teren,
                          index: index,
                          onReservationCancelled: (int index) {
                            _refreshData();
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
