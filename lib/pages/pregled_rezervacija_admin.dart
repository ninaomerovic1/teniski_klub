import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:teniski_klub_projekat/widgets/prikaz_rezervacije.dart';
import '../services/tereni_service.dart';
import '../services/rezervacija_service.dart';
import '../models/Rezervacija.dart';
import '../models/Teren.dart';
import '../widgets/date_picker.dart'; // Uvezi vaš DatePicker widget

class FiltriranjeRezervacija extends StatefulWidget {
  const FiltriranjeRezervacija({super.key});

  @override
  State<FiltriranjeRezervacija> createState() => _FiltriranjeRezervacijaState();
}

class _FiltriranjeRezervacijaState extends State<FiltriranjeRezervacija> {
  final TereniService _tereniService = TereniService();
  final RezervacijaService _rezervacijaService = RezervacijaService();

  List<Teren> _tereni = [];
  List<String> _datumi = [];
  DateTime? _selectedDate;
  String? _selectedCourt;
  List<Rezervacija> _filteredRezervacije = [];
  bool _isLoading = true;
  List<Teren> _courts = [];

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
      // Ovde možeš dodati kod za ažuriranje dostupnih satnica prema izabranom datumu
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    await selectDate(context, _onDateSelected);
  }

  Future<void> _filterReservations() async {
    if (_selectedCourt != null && _selectedDate != null) {
      try {
        final date = DateFormat('dd.MM.yyyy').format(_selectedDate!);
        final rezervacije = await _rezervacijaService.rezervacijeFiltriranje(
            _selectedCourt, date);

        setState(() {
          _filteredRezervacije = rezervacije;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Greška pri filtriranju rezervacija: $e')),
        );
      }
    }
    for (int i = 0; i < _filteredRezervacije.length; i++) {
      print(_filteredRezervacije[i].satnica);
    }
  }

  Future<void> _refreshData() async {
    await _filterReservations();
    setState(() {
      print("USAO U SET STATE");
    });
  }

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
        child: Column(
          children: [
            SizedBox(height: 16.0), // Malo prostora sa vrha
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                width: 400.0, // Smanjena širina
                //height: 300,
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
                      offset: Offset(0, 3), // Promena pozicije senke
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      'Filtriraj rezervacije',
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
                          child: Text(
                              teren.naziv), // Pretpostavljam da Teren ima naziv
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
                            MaterialStateProperty.all(Colors.orange),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        minimumSize: MaterialStateProperty.all(
                            Size(double.infinity, 48)),
                        textStyle:
                            MaterialStateProperty.all(TextStyle(fontSize: 16)),
                      ),
                      onPressed: _filterReservations,
                      child: Text('Filtriraj', textAlign: TextAlign.center),
                    ),
                    SizedBox(height: 8),
                  ],
                ),
              ),
            ),
            Expanded(
              child: _filteredRezervacije.isEmpty
                  ? Center(
                      child: Container(
                        padding: EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(color: Colors.grey, width: 1),
                        ),
                        child: Text(
                          'Nema rezervacija',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.all(16.0),
                      itemCount: _filteredRezervacije.length,
                      itemBuilder: (context, index) {
                        final rezervacija = _filteredRezervacije[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: PrikazRezervacije(
                            datum: rezervacija.datum,
                            vreme: rezervacija.satnica,
                            teren: rezervacija.teren,
                            index: index,
                            onReservationCancelled: (int cancelledIndex) async {
                              setState(() {
                                print("OVDE SAM");
                                _filteredRezervacije = [];
                                _filterReservations();
                              });
                            },
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
