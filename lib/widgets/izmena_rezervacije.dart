// ignore_for_file: prefer_const_constructors, use_super_parameters, library_private_types_in_public_api, use_build_context_synchronously, prefer_for_elements_to_map_fromiterable
import 'package:flutter/material.dart';
import 'package:teniski_klub_projekat/services/tereni_service.dart';
import '../services/termin_service.dart'; // Importuj TerminiService
import '../services/rezervacija_service.dart'; // Importuj RezervacijaService
import '../models/Teren.dart';

const Color availableColor =
    Color.fromARGB(255, 4, 113, 7); // Zeleno za slobodne termine
const Color unavailableColor = Color(0xFFFF4D4D); // Crveno za zauzete termine

class IzmeniRezervaciju extends StatefulWidget {
  final String datum;
  final String vreme;
  final String nazivTerena;
  final ValueChanged<String> onTimeUpdated;

  const IzmeniRezervaciju({
    required this.datum,
    required this.vreme,
    required this.nazivTerena,
    required this.onTimeUpdated,
    Key? key,
  }) : super(key: key);

  @override
  _IzmeniRezervacijuState createState() => _IzmeniRezervacijuState();
}

class _IzmeniRezervacijuState extends State<IzmeniRezervaciju> {
  String? _selectedTime;
  Map<String, bool> _availableTimesMap = {};
  final TerminService _terminiService = TerminService();
  final RezervacijaService _rezervacijaService = RezervacijaService();
  final TereniService _tereniService = TereniService();
  late Future<Teren?> _terenFuture;
  List<String> _availableTimes = [];

  @override
  void initState() {
    super.initState();
    _terenFuture = _tereniService.getTerenById(widget.nazivTerena);
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    print("Naziv terena");
    print(widget.nazivTerena);
    try {
      final Teren? teren = await _terenFuture;
      if (teren == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content:
                Text('Teren sa nazivom ${widget.nazivTerena} nije pronađen.')));
        return;
      }
      print(teren.id);
      print("EVO ME");
      final date = widget.datum;
      print(date);
      final terenId = teren.id; // Koristi ID iz učitanog terena
      print(terenId);
      final result = await _terminiService.fetchTermini(date, terenId);
      print("REZULTAT");
      print(result);
      final termini = result['termini'] as List<dynamic>;
      print("UCITAO TERMINE");
      print(termini);
      setState(() {
        _availableTimesMap = Map.fromIterable(
          termini,
          key: (item) => item['satnica'] as String,
          value: (item) => item['isSlobodan'] as bool,
        );
        _availableTimes = _availableTimesMap.keys.toList()..sort();
        print("SATNICE SORTIRano");
        print(_availableTimes);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri učitavanju termina: $e')));
    }
  }

  Future<void> _updateReservation() async {
    if (_selectedTime != null && _availableTimesMap[_selectedTime]!) {
      try {
        final oldTime = widget.vreme;
        final newTime = _selectedTime!;
        final date = widget.datum;
        final teren = await _terenFuture;
        String idTer = "";
        if (teren != null) {
          idTer = teren.id;
        }
        final terenId = idTer;

        // Ažuriraj rezervaciju u bazi
        await _rezervacijaService.updateRezervacijaTime(
          oldTime, date, terenId, // Pretpostavljam da Rezervacija ima id
          newTime,
        );

        widget.onTimeUpdated(newTime);

        // Ažuriraj termine u bazi
        await _terminiService.updateTerminStatus(date, oldTime, terenId, true);
        await _terminiService.updateTerminStatus(date, newTime, terenId, false);

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Rezervacija uspešno izmenjena!')));
        Navigator.pop(context); // Zatvori dijalog nakon izmene
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Greška pri izmeni rezervacije: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'Izmena rezervacije',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 4, 113, 7),
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Datum: ${widget.datum}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 8),
            Text(
              'Teren: ${widget.nazivTerena}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            Text(
              'Vreme rezervacije: ${widget.vreme}',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.orange),
                foregroundColor: WidgetStateProperty.all(Colors.white),
                minimumSize:
                    WidgetStateProperty.all(Size(double.infinity, 48)),
                textStyle: WidgetStateProperty.all(TextStyle(fontSize: 16)),
              ),
              onPressed: _checkAvailability,
              child:
                  Text('Izmeni vreme rezervacije', textAlign: TextAlign.center),
            ),
            SizedBox(height: 20),
            if (_availableTimes.isNotEmpty)
              GridView.builder(
                shrinkWrap: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: _availableTimes.length,
                itemBuilder: (context, index) {
                  final time = _availableTimes[index];
                  final color = _availableTimesMap[time]!
                      ? availableColor
                      : unavailableColor;
                  return GestureDetector(
                    onTap: () {
                      if (_availableTimesMap[time]!) {
                        setState(() {
                          _selectedTime = time;
                        });
                      }
                    },
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _selectedTime == time
                              ? Colors.orange
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        time,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              )
            else
              Center(
                child: Text(
                  'Nema dostupnih termina',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      WidgetStateProperty.all(Color.fromARGB(255, 4, 113, 7)),
                  foregroundColor: WidgetStateProperty.all(Colors.white),
                  minimumSize:
                      WidgetStateProperty.all(Size(double.infinity, 48)),
                  textStyle: WidgetStateProperty.all(TextStyle(fontSize: 16)),
                ),
                onPressed: _updateReservation,
                child: Text('Izmeni rezervaciju', textAlign: TextAlign.center),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
