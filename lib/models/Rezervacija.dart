// ignore_for_file: file_names

class Rezervacija {
  String? id;
  final String? korisnik;
  final String teren;
  final String datum;
  final String satnica;

  Rezervacija({
    this.id,
    required this.korisnik,
    required this.teren,
    required this.datum,
    required this.satnica,
  });

  // Pretvori JSON u Rezervacija objekat
  factory Rezervacija.fromJson(Map<String, dynamic> json) {
    return Rezervacija(
      id: json['id'] as String?,
      korisnik: json['korisnik'] as String,
      teren: json['teren'] as String,
      datum: json['datum'] as String,
      satnica: json['satnica'] as String,
    );
  }

  // Pretvori Rezervacija objekat u JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'korisnik': korisnik,
      'teren': teren,
      'datum': datum,
      'satnica': satnica,
    };
  }
}
