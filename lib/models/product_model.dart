import 'package:equatable/equatable.dart';

class Product extends Equatable {
  final String id;
  final String name;
  final String description;
  final double mrp;
  final double offer;
  final double priceAfterOffer;
  final double price;
  final String imageUrl;
  final String category;
  final int stock;
  final bool isTopSelling;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Product({
    required this.id,
    required this.name,
    required this.description,
    required this.mrp,
    required this.offer,
    required this.priceAfterOffer,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.stock,
    this.isTopSelling = false,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      mrp: (json['mrp'] as num?)?.toDouble() ?? 0.0,
      offer: (json['offer'] as num?)?.toDouble() ?? 0.0,
      priceAfterOffer: (json['price_after_offer'] as num?)?.toDouble() ?? 0.0,
      price: (json['price'] as num).toDouble(),
      imageUrl: json['image_url'] as String,
      category: json['category'] as String,
      stock: json['stock'] as int,
      isTopSelling: json['is_top_selling'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'mrp': mrp,
      'offer': offer,
      'price_after_offer': priceAfterOffer,
      'price': price,
      'image_url': imageUrl,
      'category': category,
      'stock': stock,
      'is_top_selling': isTopSelling,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    mrp,
    offer,
    priceAfterOffer,
    price,
    imageUrl,
    category,
    stock,
    isTopSelling,
    createdAt,
    updatedAt,
  ];
}
