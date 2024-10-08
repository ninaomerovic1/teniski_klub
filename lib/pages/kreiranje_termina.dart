// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Potrebno za formatiranje datuma
import 'package:teniski_klub_projekat/models/Teren.dart';
import '../widgets/date_picker.dart'; // Importuj novi fajl za DatePicker
import '../widgets/time_dialog.dart'; // Importuj novi fajl za TimeDialog
import '../services/tereni_service.dart';
import '../services/termin_service.dart'; // Dodaj novi servis
import '../models/Termin.dart';

class KreirajTermin extends StatefulWidget {
  @override
  _KreirajTerminState createState() => _KreirajTerminState();
}

class _KreirajTerminState extends State<KreirajTermin> {
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedCourt;
  List<Teren> _courts = [];
  final TereniService _tereniService = TereniService();
  final TerminService _terminService = TerminService();
  bool _isProcessing = false;
  double _progress = 0.0;

  @override
  void initState() {
    super.initState();
    _loadTereni();
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

  void _onDateSelected(DateTime? date) {
    setState(() {
      _selectedDate = date;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    await selectDate(context, _onDateSelected);
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (BuildContext context) {
        return TimeDialog(
          initialHour: _selectedTime?.hour ?? 6,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _kreirajTermin() async {
    if (_selectedDate != null && _selectedTime != null && _selectedCourt != null) {
      final String formattedDate = DateFormat('dd.MM.yyyy').format(_selectedDate!);
      final String formattedTime = _selectedTime!.format(context);

      final termin = Termin(
        datum: formattedDate,
        satnica: formattedTime,
        teren: _selectedCourt!,
        isSlobodan: true,
      );
      bool terminPostoji = await _terminService.postojiTermin(termin);
  
      if (terminPostoji) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Termin sa ovim datumom, satnicom i terenom već postoji.'),
          backgroundColor: Colors.red,
        ),
      );
      return; // Prekidamo izvršavanje ako termin već postoji
    }


      await _terminService.kreirajTermin(termin);

      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Termin je uspešno kreiran'),
        
      ),
    );
      // Očisti selektovane vrednosti nakon uspešnog kreiranja termina
      setState(() {
        _selectedDate = null;
        _selectedTime = null;
        _selectedCourt = _courts.isNotEmpty ? _courts[0].id : null;
      });
    } else {
      print('Molimo popunite sve podatke.');
    }
  }

  Future<void> _kreirajSveTermineZaDvaMeseca() async {
    if (_selectedDate == null || _selectedCourt == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Molimo izaberite datum i teren.'),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  setState(() {
      _isProcessing = true;
      _progress = 0.0;
    });


  DateTime pocetniDatum = _selectedDate!;
  DateTime krajnjiDatum = pocetniDatum.add(Duration(days: 7)); // Period od nedelju dana

  List<int> satnice = List<int>.generate(17, (index) => 6 + index); // Satnice od 6 do 22
  int totalTerminCount = 7 * satnice.length; // Ukupan broj termina
  int currentTerminCount = 0;

  for (DateTime datum = pocetniDatum;
      datum.isBefore(krajnjiDatum);
      datum = datum.add(Duration(days: 1))) {
    String formattedDate = DateFormat('dd.MM.yyyy').format(datum);

    for (int satnica in satnice) {
      TimeOfDay vreme = TimeOfDay(hour: satnica, minute: 0);
      String formattedTime = vreme.format(context);

      Termin termin = Termin(
        datum: formattedDate,
        satnica: formattedTime,
        teren: _selectedCourt!,
        isSlobodan: true,
      );

      bool terminPostoji = await _terminService.postojiTermin(termin);
      if (!terminPostoji) {
        await _terminService.kreirajTermin(termin);
      }

      currentTerminCount++;
        setState(() {
          _progress = currentTerminCount / totalTerminCount;
        });

    }
  }

  setState(() {
      _isProcessing = false;
    });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Svi termini za narednih nedelju dana su uspešno kreirani!'),
      backgroundColor: Colors.green,
    ),
  );
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
            width: 300, // širina belog prozora
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
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
                  'Kreiraj termin',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 4, 113, 7),
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
                TextField(
                  decoration: InputDecoration(
                    labelText: _selectedTime != null
                        ? 'Izabrana satnica: ${_selectedTime!.format(context)}'
                        : 'Izaberi satnicu',
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
                  onTap: () => _selectTime(context),
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
                    onPressed: _kreirajTermin,
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          Color.fromARGB(255, 4, 113, 7)), // Zeleno
                      foregroundColor: WidgetStateProperty.all(
                          Colors.white), // Boja teksta
                      minimumSize: WidgetStateProperty.all(
                          Size(double.infinity, 50)), // Širina i visina dugmeta
                      textStyle:
                          WidgetStateProperty.all(TextStyle(fontSize: 16)),
                    ),
                    
                    child: Center(child: Text('Kreiraj termin')),
                  ),
                ),
                SizedBox(height: 20),
                if (_isProcessing)
                Column(
                  children: [
                  LinearProgressIndicator(
                    value: _progress,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.orange),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Kreiranje termina... ${(_progress * 100).toStringAsFixed(1)}%',
                    style: TextStyle(color: Colors.orange),
                  ),
                ],
              ),
              SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: WidgetStateProperty.all(
                          Colors.orange), // Narandžasto
                      foregroundColor: WidgetStateProperty.all(
                          Colors.white), // Boja teksta
                      minimumSize: WidgetStateProperty.all(
                          Size(double.infinity, 50)), // Širina i visina dugmeta
                      textStyle:
                          WidgetStateProperty.all(TextStyle(fontSize: 16)),
                    ),
                    onPressed: () {
                      _isProcessing ? null :_kreirajSveTermineZaDvaMeseca();
                    },
                    child: Align(
                        alignment: Alignment.center,
                        child: Text(
                          'Kreiraj sve termine za narednih nedelju dana',
                          textAlign: TextAlign.center,
                        )),
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
