class Teren {
  final String id;
  final String naziv;

  Teren({required this.id, required this.naziv});

  factory Teren.fromJson(Map<String, dynamic> json, String id) {
    return Teren(
      id: id,
      naziv: json['naziv'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'naziv': naziv,
    };
  }
}
