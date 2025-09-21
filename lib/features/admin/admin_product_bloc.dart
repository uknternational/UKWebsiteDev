import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';
import '../products/product_repository.dart';
import 'package:go_router/go_router.dart';

part 'admin_product_event.dart';
part 'admin_product_state.dart';

class AdminProductBloc extends Bloc<AdminProductEvent, AdminProductState> {
  final ProductRepository repository;

  AdminProductBloc(this.repository) : super(AdminProductInitial()) {
    on<LoadAdminProducts>((event, emit) async {
      emit(AdminProductLoading());
      try {
        final products = await repository.fetchAllProducts();
        emit(AdminProductLoaded(products));
      } catch (e) {
        emit(AdminProductError('Failed to load products'));
      }
    });

    on<AddProduct>((event, emit) async {
      emit(AdminProductLoading());
      try {
        await repository.addProduct(event.product);
        final products = await repository.fetchAllProducts();
        emit(AdminProductLoaded(products));
      } catch (e) {
        emit(AdminProductError('Failed to add product'));
      }
    });

    on<UpdateProduct>((event, emit) async {
      emit(AdminProductLoading());
      try {
        await repository.updateProduct(event.product);
        final products = await repository.fetchAllProducts();
        emit(AdminProductLoaded(products));
      } catch (e) {
        emit(AdminProductError('Failed to update product'));
      }
    });

    on<DeleteProduct>((event, emit) async {
      emit(AdminProductLoading());
      try {
        await repository.deleteProduct(event.productId);
        final products = await repository.fetchAllProducts();
        emit(AdminProductLoaded(products));
      } catch (e) {
        emit(AdminProductError('Failed to delete product'));
      }
    });
  }
}
