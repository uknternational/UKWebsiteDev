part of 'admin_coupon_bloc.dart';

abstract class AdminCouponEvent extends Equatable {
  const AdminCouponEvent();
  @override
  List<Object?> get props => [];
}

class LoadAdminCoupons extends AdminCouponEvent {}

class AddCoupon extends AdminCouponEvent {
  final Coupon coupon;
  const AddCoupon(this.coupon);
  @override
  List<Object?> get props => [coupon];
}

class UpdateCoupon extends AdminCouponEvent {
  final Coupon coupon;
  const UpdateCoupon(this.coupon);
  @override
  List<Object?> get props => [coupon];
}

class DeleteCoupon extends AdminCouponEvent {
  final String couponId;
  const DeleteCoupon(this.couponId);
  @override
  List<Object?> get props => [couponId];
}
