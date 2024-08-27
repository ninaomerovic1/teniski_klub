// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:teniski_klub_projekat/models/Termin.dart';
import 'package:teniski_klub_projekat/services/termin_service.dart';
import 'package:teniski_klub_projekat/services/tereni_service.dart';
import 'package:intl/intl.dart';
import '../widgets/date_picker.dart'; // Uvezi vaš DatePicker widget
import '../models/Teren.dart';
import '../widgets/prikaz_termina.dart';

class PregledTermina extends StatefulWidget {
  @override
  _PregledTerminaState createState() => _PregledTerminaState();
}

class _PregledTerminaState extends State<PregledTermina> {
  final TereniService _tereniService = TereniService();
  final TerminService _terminService = TerminService();
  DateTime? _selectedDate;
  String? _selectedCourt;
  List<Termin> _filteredTermini = [];
  List<Teren> _courts = [];

  @override
  void initState() {
    super.initState();
    _loadTereni();
  }

  Future<void> _loadTereni() async {
    try {
      final courts = await _tereniService.getTereni();
      setState(() {
        _courts = courts;
        _selectedCourt = _courts.isNotEmpty ? _courts[0].id : "";
      });
    } catch (error) {
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

  Future<void> _filterTermini() async {
    if (_selectedCourt != null && _selectedDate != null) {
      try {
        final date = DateFormat('dd.MM.yyyy').format(_selectedDate!);
        final result = await _terminService.fetchTermini(date, _selectedCourt!);
        final termini = (result['termini'] as List<dynamic>).map((item) {
          // Pretvoriti svaki item u Map<String, dynamic>
          return item as Map<String, dynamic>;
        }).toList();

        print("UCITAO SAM TERMINE");
        setState(() {
          _filteredTermini = termini.map((item) {
            final id = item['id'] as String; // ID iz rezultata
            final terminData = item; // Map<String, dynamic>

            return Termin.fromJson(terminData, id);
          }).toList();

          _filteredTermini.sort((a, b) {
            // Sortiranje prema satnici, format je HH:00
            return a.satnica.compareTo(b.satnica);
          });
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri filtriranju termina: $e')),
        );
      }
    }
  }

  Future<void> _refreshData() async {
    print("USAO SAM U REFERSH");
    await _filterTermini();
    setState(() {});
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
        child: Column(
          children: [
            SizedBox(height: 16.0), // Malo prostora sa vrha
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 400.0, // Smanjena širina
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Pregled termina',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color.fromARGB(255, 4, 113, 7),
                      ),
                    ),
                    SizedBox(height: 15.0),
                    DropdownButtonFormField<String>(
                      value: _selectedCourt,
                      hint: Text('Izaberi teren'),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedCourt = newValue;
                        });
                      },
                      items:
                          _courts.map<DropdownMenuItem<String>>((Teren teren) {
                        return DropdownMenuItem<String>(
                          value: teren.id,
                          child: Text(teren.naziv),
                        );
                      }).toList(),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.orange, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.orange, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.orange, width: 2),
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
                          borderSide:
                              BorderSide(color: Colors.orange, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.orange, width: 2),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              BorderSide(color: Colors.orange, width: 2),
                        ),
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                            WidgetStateProperty.all(Colors.orange),
                        foregroundColor:
                            WidgetStateProperty.all(Colors.white),
                        minimumSize: WidgetStateProperty.all(
                            Size(double.infinity, 48)),
                        textStyle:
                            WidgetStateProperty.all(TextStyle(fontSize: 16)),
                      ),
                      onPressed: _filterTermini,
                      child: Text('Filtriraj', textAlign: TextAlign.center),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _filteredTermini.isEmpty
                  ? Center(
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.grey, width: 1.0),
                        ),
                        child: Text(
                          'Nema termina',
                          style: TextStyle(fontSize: 18.0, color: Colors.black),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.0),
                      itemCount: _filteredTermini.length,
                      itemBuilder: (context, index) {
                        final termin = _filteredTermini[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: PrikazTermina(
                            id: termin.id,
                            datum: termin.datum,
                            vreme: termin.satnica,
                            teren: termin.teren,
                            jeSlobodan: termin.isSlobodan,
                            onOtkazi: _refreshData,
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
