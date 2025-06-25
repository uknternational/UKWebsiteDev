class CustomerReview {
  final String id;
  final String customerName;
  final String reviewText;
  final double rating;
  final String? imageUrl;
  final bool isActive;
  final DateTime createdAt;

  const CustomerReview({
    required this.id,
    required this.customerName,
    required this.reviewText,
    required this.rating,
    this.imageUrl,
    required this.isActive,
    required this.createdAt,
  });

  factory CustomerReview.fromJson(Map<String, dynamic> json) {
    return CustomerReview(
      id: json['id'] as String,
      customerName: json['customer_name'] as String,
      reviewText: json['review_text'] as String,
      rating: (json['rating'] as num).toDouble(),
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_name': customerName,
      'review_text': reviewText,
      'rating': rating,
      'image_url': imageUrl,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  CustomerReview copyWith({
    String? id,
    String? customerName,
    String? reviewText,
    double? rating,
    String? imageUrl,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CustomerReview(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      reviewText: reviewText ?? this.reviewText,
      rating: rating ?? this.rating,
      imageUrl: imageUrl ?? this.imageUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
