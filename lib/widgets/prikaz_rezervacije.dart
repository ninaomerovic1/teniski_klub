import 'package:flutter/material.dart';

class PrikazRezervacije extends StatelessWidget {
  final String datum;
  final String vreme;
  final String teren;
  final VoidCallback onEdit;
  final VoidCallback onCancel;

  const PrikazRezervacije({
    super.key,
    required this.datum,
    required this.vreme,
    required this.teren,
    required this.onEdit,
    required this.onCancel,
  });

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
            'Datum: $datum',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          SizedBox(height: 8),
          Text(
            'Vreme: $vreme',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          SizedBox(height: 8),
          Text(
            'Teren: $teren',
            style: TextStyle(fontSize: 16, color: Colors.black),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(Colors.orange),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: onEdit,
                child: Text('Izmeni'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(Colors.red),
                  foregroundColor: MaterialStateProperty.all(Colors.white),
                ),
                onPressed: onCancel,
                child: Text('Otkazi'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
