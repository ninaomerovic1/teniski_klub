// ignore_for_file: prefer_const_constructors, prefer_const_constructors_in_immutables, use_key_in_widget_constructors, library_private_types_in_public_api
import 'package:flutter/material.dart';

class TimeDialog extends StatefulWidget {
  final int initialHour;

  TimeDialog({required this.initialHour});

  @override
  _TimeDialogState createState() => _TimeDialogState();
}

class _TimeDialogState extends State<TimeDialog> {
  late int _selectedHour;

  @override
  void initState() {
    super.initState();
    _selectedHour = widget.initialHour;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Izaberi satnicu'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DropdownButton<int>(
            value: _selectedHour,
            items: List.generate(17, (index) {
              return DropdownMenuItem<int>(
                value: 6 + index, // Vreme od 06:00 do 22:00
                child: Text('${6 + index}:00'),
              );
            }),
            onChanged: (int? value) {
              setState(() {
                _selectedHour = value!;
              });
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(null);
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.orange, // Tekst dugmeta
          ),
          child: Text('Otkaži'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context)
                .pop(TimeOfDay(hour: _selectedHour, minute: 0));
          },
          style: TextButton.styleFrom(
            foregroundColor: Colors.orange, // Tekst dugmeta
          ),
          child: Text('Izaberi'),
        ),
      ],
    );
  }
}
