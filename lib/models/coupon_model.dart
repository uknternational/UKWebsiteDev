import 'package:equatable/equatable.dart';

class Coupon extends Equatable {
  final String id;
  final String code;
  final double discount;
  final DateTime expiry;
  final bool isActive;
  final DateTime createdAt;

  const Coupon({
    required this.id,
    required this.code,
    required this.discount,
    required this.expiry,
    required this.isActive,
    required this.createdAt,
  });

  factory Coupon.fromJson(Map<String, dynamic> json) {
    return Coupon(
      id: json['id'] as String,
      code: json['code'] as String,
      discount: (json['discount'] as num).toDouble(),
      expiry: DateTime.parse(json['expiry'] as String),
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'discount': discount,
      'expiry': expiry.toIso8601String(),
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [id, code, discount, expiry, isActive, createdAt];
}
