import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'product_repository.dart';
import '../../models/product_model.dart';

part 'product_event.dart';
part 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc(this.repository) : super(ProductInitial()) {
    on<LoadProducts>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await repository.fetchAllProducts();
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError('Failed to load products'));
      }
    });

    on<SearchProducts>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await repository.searchProducts(event.query);
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError('Failed to search products'));
      }
    });

    on<FilterProductsByCategory>((event, emit) async {
      emit(ProductLoading());
      try {
        final products = await repository.fetchProductsByCategory(
          event.category,
        );
        emit(ProductLoaded(products));
      } catch (e) {
        emit(ProductError('Failed to filter products by category'));
      }
    });
  }
}
