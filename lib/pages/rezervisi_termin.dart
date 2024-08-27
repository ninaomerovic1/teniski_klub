// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, use_build_context_synchronously, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Potrebno za formatiranje datuma
import '../widgets/date_picker.dart'; // Importuj novi fajl za DatePicker
import '../services/termin_service.dart'; // Importuj TerminiService
import '../services/rezervacija_service.dart'; // Importuj RezervacijaService
import '../models/Rezervacija.dart'; // Importuj model rezervacije
import '../models/Teren.dart';
import '../services/tereni_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Color availableColor =
    Color.fromARGB(255, 4, 113, 7); // Zeleno za slobodne termine
Color unavailableColor = Color(0xFFFF4D4D); // Crveno za zauzete termine

class Rezervisi extends StatefulWidget {
  Rezervisi({super.key});

  @override
  State<Rezervisi> createState() => _RezervisiState();
}

class _RezervisiState extends State<Rezervisi> {
  DateTime? _selectedDate;
  String? _selectedCourt;
  // Lista raspoloživih satnica će se popuniti nakon HTTP zahteva
  List<String> _availableTimes = [];
  String? _selectedTime;
  final TerminService _terminiService = TerminService();
  final RezervacijaService _rezervacijaService = RezervacijaService();
  final TereniService _tereniService = TereniService();
  Map<String, bool> _availableTimesMap = {};
  List<Teren> _courts = [];

  @override
  void initState() {
    super.initState();
    _loadTereni();
  }

  void _onDateSelected(DateTime? date) {
    setState(() {
      _selectedDate = date;
      // Ovde možeš dodati kod za ažuriranje dostupnih satnica prema izabranom datumu
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    await selectDate(context, _onDateSelected);
  }

  Future<void> _loadTereni() async {
    print("USAO U LOAD TERENI");
    try {
      print("U LOAD TERENI SAM");
      final courts = await _tereniService.getTereni();
      print("UCITALI SE");
      print('Tereni učitani: $courts');
      setState(() {
        _courts = courts; // Direktno dodeljujemo listu terena
        _selectedCourt = _courts.isNotEmpty ? _courts[0].id : null;
      });
    } catch (error) {
      print("U OVOM CATCHU SAM");
      print('Došlo je do greške: $error');
    }
  }

  Future<void> _checkAvailability() async {
    if (_selectedDate != null && _selectedCourt != null) {
      try {
        final date = DateFormat('dd.MM.yyyy').format(_selectedDate!);
        final result =
            await _terminiService.fetchTermini(date, _selectedCourt!);

        final termini = result['termini'] as List<dynamic>;
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
  }

  Future<void> _reserveTerm() async {
    if (_selectedDate != null &&
        _selectedCourt != null &&
        _selectedTime != null) {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('email');
      final rezervacija = Rezervacija(
        datum: DateFormat('dd.MM.yyyy').format(_selectedDate!),
        satnica: _selectedTime!,
        teren: _selectedCourt!,
        korisnik: email, // Ovde treba dodati stvarni ID korisnika
      );

      try {
        await _rezervacijaService.createRezervacija(rezervacija);
        await _terminiService.updateTerminStatus(
          DateFormat('dd.MM.yyyy').format(_selectedDate!),
          _selectedTime!,
          _selectedCourt!,
          false,
        );
        await _checkAvailability();
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Termin uspešno rezervisan!')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Greška pri rezervaciji: $e')));
      }
    }
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
        child: Center(
          child: Container(
            padding: EdgeInsets.all(16.0),
            constraints: BoxConstraints(
              maxWidth: 300, // Širina belog prozora
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: Offset(0, 3), // Pozicija senke
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Visina se prilagođava sadržaju
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Rezerviši termin',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 4, 113, 7),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    labelText: _selectedDate != null
                        ? 'Izabrani datum: ${DateFormat('dd.MM.yyyy').format(_selectedDate!)}'
                        : 'Izaberi datum',
                    labelStyle: TextStyle(color: Colors.black),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.orange, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.orange, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.orange, width: 2),
                    ),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(context),
                ),
                SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  value: _selectedCourt,
                  hint: Text('Izaberi teren'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCourt = newValue;
                    });
                  },
                  items: _courts.map<DropdownMenuItem<String>>((Teren teren) {
                    return DropdownMenuItem<String>(
                      value: teren.id,
                      child: Text(
                          teren.naziv), // Pretpostavljam da Teren ima naziv
                    );
                  }).toList(),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.orange, width: 2),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.orange, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.orange, width: 2),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(Colors.orange),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      minimumSize:
                          WidgetStateProperty.all(Size(double.infinity, 48)),
                      textStyle:
                          WidgetStateProperty.all(TextStyle(fontSize: 16)),
                    ),
                    onPressed: _checkAvailability,
                    child: Text('Proveri raspoloživost',
                        textAlign: TextAlign.center),
                  ),
                ),
                SizedBox(height: 20),
                // Prostor za raspoložive satnice
                if (_availableTimes.isNotEmpty)
                  Container(
                    height: 200, // Visina grid-a
                    child: GridView.builder(
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
                        final isSelected = _selectedTime == time;
                        //final isAvailable = _availableTimesMap[time] ?? false;
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
                    ),
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
                      backgroundColor: WidgetStateProperty.all(
                          Color.fromARGB(255, 4, 113, 7)),
                      foregroundColor: WidgetStateProperty.all(Colors.white),
                      minimumSize:
                          WidgetStateProperty.all(Size(double.infinity, 48)),
                      textStyle:
                          WidgetStateProperty.all(TextStyle(fontSize: 16)),
                    ),
                    onPressed: () {
                      _reserveTerm();
                    },
                    child:
                        Text('Rezerviši termin', textAlign: TextAlign.center),
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
