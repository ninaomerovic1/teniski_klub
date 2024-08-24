import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Potrebno za formatiranje datuma
import '../widgets/date_picker.dart'; // Importuj novi fajl za DatePicker

class Rezervisi extends StatefulWidget {
  const Rezervisi({super.key});

  @override
  State<Rezervisi> createState() => _RezervisiState();
}

class _RezervisiState extends State<Rezervisi> {
  DateTime? _selectedDate;
  String? _selectedCourt;
  // Lista raspoloživih satnica će se popuniti nakon HTTP zahteva
  List<String> _availableTimes = []; 
  String? _selectedTime;

  void _onDateSelected(DateTime? date) {
    setState(() {
      _selectedDate = date;
      // Ovde možeš dodati kod za ažuriranje dostupnih satnica prema izabranom datumu
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    await selectDate(context, _onDateSelected);
  }

  void _checkAvailability() {
    // Kod za proveru raspoloživosti i ažuriranje liste dostupnih satnica preko HTTP zahteva
    // Ovde ćeš dodati kod za HTTP zahtev kada budeš spreman
    setState(() {
      _availableTimes = []; // Trenutno ostavljamo praznu listu
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
                  items: <String>['Teren 1', 'Teren 2', 'Teren 3', 'Teren 4']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
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
                      backgroundColor: MaterialStateProperty.all(Colors.orange),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      minimumSize: MaterialStateProperty.all(Size(double.infinity, 48)),
                      textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
                    ),
                    onPressed: _checkAvailability,
                    child: Text('Proveri raspoloživost', textAlign: TextAlign.center),
                  ),
                ),
                SizedBox(height: 20),
                // Prostor za raspoložive satnice
                if (_availableTimes.isEmpty) 
                  Text(
                    'Raspoložive satnice će biti prikazane ovde.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                if (_availableTimes.isNotEmpty) 
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _availableTimes.map((time) {
                      return Text(time, style: TextStyle(fontSize: 16));
                    }).toList(),
                  ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(Color.fromARGB(255, 4, 113, 7)),
                      foregroundColor: MaterialStateProperty.all(Colors.white),
                      minimumSize: MaterialStateProperty.all(Size(double.infinity, 48)),
                      textStyle: MaterialStateProperty.all(TextStyle(fontSize: 16)),
                    ),
                    onPressed: () {
                      // Akcija za rezervaciju termina
                    },
                    child: Text('Rezerviši termin', textAlign: TextAlign.center),
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
