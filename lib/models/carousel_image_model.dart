class CarouselImage {
  final String id;
  final String imageUrl;
  final bool isActive;
  final int displayOrder;
  final DateTime createdAt;

  const CarouselImage({
    required this.id,
    required this.imageUrl,
    required this.isActive,
    required this.displayOrder,
    required this.createdAt,
  });

  factory CarouselImage.fromJson(Map<String, dynamic> json) {
    return CarouselImage(
      id: json['id'] as String,
      imageUrl: json['image_url'] as String,
      isActive: json['is_active'] as bool,
      displayOrder: json['display_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'image_url': imageUrl,
      'is_active': isActive,
      'display_order': displayOrder,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CarouselImage copyWith({
    String? id,
    String? imageUrl,
    bool? isActive,
    int? displayOrder,
    DateTime? createdAt,
  }) {
    return CarouselImage(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      displayOrder: displayOrder ?? this.displayOrder,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
