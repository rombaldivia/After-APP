class Affiliate {
  final String uidHex;
  final String name;
  final String? phone;
  final int points;

  const Affiliate({
    required this.uidHex,
    required this.name,
    this.phone,
    this.points = 0,
  });

  Map<String, dynamic> toMap() => {
        'uidHex': uidHex,
        'name': name,
        'phone': phone,
        'points': points,
      };

  static Affiliate fromMap(Map<String, dynamic> m) => Affiliate(
        uidHex: (m['uidHex'] ?? '') as String,
        name: (m['name'] ?? '') as String,
        phone: m['phone'] as String?,
        points: (m['points'] as int?) ?? 0,
      );

  Affiliate copyWith({String? name, String? phone, int? points}) => Affiliate(
        uidHex: uidHex,
        name: name ?? this.name,
        phone: phone ?? this.phone,
        points: points ?? this.points,
      );
}
