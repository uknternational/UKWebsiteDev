import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/coupon_model.dart';
import 'coupon_repository.dart';

part 'admin_coupon_event.dart';
part 'admin_coupon_state.dart';

class AdminCouponBloc extends Bloc<AdminCouponEvent, AdminCouponState> {
  final CouponRepository repository;

  AdminCouponBloc(this.repository) : super(AdminCouponInitial()) {
    on<LoadAdminCoupons>((event, emit) async {
      emit(AdminCouponLoading());
      try {
        final coupons = await repository.fetchAllCoupons();
        emit(AdminCouponLoaded(coupons));
      } catch (e) {
        emit(AdminCouponError('Failed to load coupons'));
      }
    });

    on<AddCoupon>((event, emit) async {
      emit(AdminCouponLoading());
      try {
        await repository.addCoupon(event.coupon);
        final coupons = await repository.fetchAllCoupons();
        emit(AdminCouponLoaded(coupons));
      } catch (e) {
        emit(AdminCouponError('Failed to add coupon'));
      }
    });

    on<UpdateCoupon>((event, emit) async {
      emit(AdminCouponLoading());
      try {
        await repository.updateCoupon(event.coupon);
        final coupons = await repository.fetchAllCoupons();
        emit(AdminCouponLoaded(coupons));
      } catch (e) {
        emit(AdminCouponError('Failed to update coupon'));
      }
    });

    on<DeleteCoupon>((event, emit) async {
      emit(AdminCouponLoading());
      try {
        await repository.deleteCoupon(event.couponId);
        final coupons = await repository.fetchAllCoupons();
        emit(AdminCouponLoaded(coupons));
      } catch (e) {
        emit(AdminCouponError('Failed to delete coupon'));
      }
    });
  }
}
