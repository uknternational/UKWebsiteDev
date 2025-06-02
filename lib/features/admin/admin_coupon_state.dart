part of 'admin_coupon_bloc.dart';

abstract class AdminCouponState extends Equatable {
  const AdminCouponState();
  @override
  List<Object?> get props => [];
}

class AdminCouponInitial extends AdminCouponState {}

class AdminCouponLoading extends AdminCouponState {}

class AdminCouponLoaded extends AdminCouponState {
  final List<Coupon> coupons;
  const AdminCouponLoaded(this.coupons);
  @override
  List<Object?> get props => [coupons];
}

class AdminCouponError extends AdminCouponState {
  final String message;
  const AdminCouponError(this.message);
  @override
  List<Object?> get props => [message];
}
