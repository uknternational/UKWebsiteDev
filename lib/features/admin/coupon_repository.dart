import 'package:supabase_flutter/supabase_flutter.dart';
import '../../models/coupon_model.dart';
import '../../services/supabase_service.dart';

class CouponRepository {
  final SupabaseClient _client = SupabaseService().client;

  Future<List<Coupon>> fetchAllCoupons() async {
    final response = await _client.from('coupons').select();
    if (response == null) return [];
    return (response as List)
        .map((json) => Coupon.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> addCoupon(Coupon coupon) async {
    await _client.from('coupons').insert(coupon.toJson());
  }

  Future<void> updateCoupon(Coupon coupon) async {
    await _client.from('coupons').update(coupon.toJson()).eq('id', coupon.id);
  }

  Future<void> deleteCoupon(String id) async {
    await _client.from('coupons').delete().eq('id', id);
  }
}
