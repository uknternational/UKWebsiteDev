part of 'admin_product_bloc.dart';

abstract class AdminProductState extends Equatable {
  const AdminProductState();
  @override
  List<Object?> get props => [];
}

class AdminProductInitial extends AdminProductState {}

class AdminProductLoading extends AdminProductState {}

class AdminProductLoaded extends AdminProductState {
  final List<Product> products;
  const AdminProductLoaded(this.products);
  @override
  List<Object?> get props => [products];
}

class AdminProductError extends AdminProductState {
  final String message;
  const AdminProductError(this.message);
  @override
  List<Object?> get props => [message];
}
