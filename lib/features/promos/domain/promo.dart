class Promo {
  final String id;
  final String title;
  final String description;
  final int pointsReward;
  final bool active;
  final String? createdAt;

  const Promo({
    required this.id,
    required this.title,
    required this.description,
    this.pointsReward = 0,
    this.active = true,
    this.createdAt,
  });

  Map<String, dynamic> toLocalMap() => {
        'title': title,
        'description': description,
        'pointsReward': pointsReward,
        'active': active,
      };

  static Promo fromMap(Map<String, dynamic> m) => Promo(
        id: (m['id'] ?? '') as String,
        title: (m['title'] ?? '') as String,
        description: (m['description'] ?? '') as String,
        pointsReward: (m['pointsReward'] as int?) ?? 0,
        active: (m['active'] as bool?) ?? true,
        createdAt: m['createdAt'] as String?,
      );
}

class PromoWithStatus {
  final Promo promo;
  final bool redeemed;
  const PromoWithStatus({required this.promo, required this.redeemed});
}
