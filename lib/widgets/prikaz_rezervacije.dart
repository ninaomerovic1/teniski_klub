// ignore_for_file: prefer_const_constructors, library_private_types_in_public_api
import 'package:flutter/material.dart';
import 'package:teniski_klub_projekat/services/rezervacija_service.dart';
import 'package:teniski_klub_projekat/services/termin_service.dart';
import '../widgets/izmena_rezervacije.dart';

class PrikazRezervacije extends StatefulWidget {
  final String datum;
  final String vreme;
  final String teren;
  final String? korisnik;
  final int index;
  final Function(int)? onReservationCancelled;

  const PrikazRezervacije({
    super.key,
    required this.datum,
    required this.vreme,
    required this.teren,
    this.korisnik,
    required this.index,
    this.onReservationCancelled,
  });

  @override
  _PrikazRezervacijeState createState() => _PrikazRezervacijeState();
}

class _PrikazRezervacijeState extends State<PrikazRezervacije> {
  late final ValueNotifier<String> _timeNotifier;

  @override
  void initState() {
    super.initState();
    _timeNotifier = ValueNotifier<String>(widget.vreme);
  }

  @override
  void dispose() {
    _timeNotifier.dispose();
    super.dispose();
  }

  Future<void> _showCancelDialog(BuildContext context) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // Korisnik mora da izabere
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Potvrda'),
          content: Text(
            'Da li ste sigurni da želite da otkažete ovu rezervaciju?',
            style: TextStyle(fontSize: 18),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: Colors.orange, width: 2),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    Color.fromARGB(255, 4, 113, 7)), // Zeleno dugme
                foregroundColor: WidgetStateProperty.all(Colors.white),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              child: Text('Odustani'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    Colors.orange), // Narandžasto dugme
                foregroundColor: WidgetStateProperty.all(Colors.white),
                shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
              ),
              child: Text('Potvrdi'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      // Ako je korisnik potvrdio, otkaži rezervaciju
      await _cancelReservation();

      widget.onReservationCancelled?.call(widget.index);

    }
  }

  Future<void> _cancelReservation() async {
    final rezervacijaService = RezervacijaService();
    final terminService = TerminService();
    try {
      print("VREME REZ");
      print(_timeNotifier.value);
      await rezervacijaService.deleteRezervacija(widget.datum,
          _timeNotifier.value, widget.teren); // Brisanje rezervacije
      await terminService.updateTerminStatus(widget.datum, _timeNotifier.value,
          widget.teren, true); // Ažuriranje statusa termina
    } catch (error) {
      print('Došlo je do greške: $error');
    }
  }

  void _onTimeUpdated(String newTime) {
    setState(() {
      _timeNotifier.value = newTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: Colors.orange, width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Datum: ${widget.datum}',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          SizedBox(height: 8),
          ValueListenableBuilder<String>(
            valueListenable: _timeNotifier,
            builder: (context, time, child) {
              return Text(
                'Vreme: $time',
                style: TextStyle(fontSize: 16, color: Colors.black),
              );
            },
          ),
          SizedBox(height: 8),
          Text(
            'Korisnik: ${widget.korisnik}',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          SizedBox(height: 8),
          Text(
            'Teren: ${widget.teren}',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.orange),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return IzmeniRezervaciju(
                        datum: widget.datum,
                        vreme: _timeNotifier.value, // Prosledi rezervaciju
                        nazivTerena: widget.teren,
                        onTimeUpdated: _onTimeUpdated,
                      );
                    },
                  );
                },
                child: Text('Izmeni'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.red),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                ),
                onPressed: () => _showCancelDialog(context),
                child: Text('Otkazi'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
