class Termin {
  String? id;
  final String datum; // Sada čuvamo datum kao string
  final String satnica; // Satnica se čuva kao string
  final String teren;
  final bool isSlobodan;

  Termin({
    this.id,
    required this.datum,
    required this.satnica,
    required this.teren,
    this.isSlobodan = true, // Polje koje označava da li je termin slobodan
  });

  factory Termin.fromJson(Map<String, dynamic> json, String terminId) {
    return Termin(
      id: json['id'] as String?,
      datum: json['datum'] as String,
      satnica: json['satnica'] as String,
      teren: json['teren'] as String,
      isSlobodan: json['isSlobodan'] as bool,
    );
  }

  // Konvertovanje objekta u mapu za slanje u Firebase Realtime Database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'datum': datum,
      'satnica': satnica,
      'teren': teren,
      'isSlobodan': isSlobodan,
    };
  }
}
