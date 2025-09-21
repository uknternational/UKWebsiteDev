part of 'admin_product_bloc.dart';

abstract class AdminProductEvent extends Equatable {
  const AdminProductEvent();
  @override
  List<Object?> get props => [];
}

class LoadAdminProducts extends AdminProductEvent {}

class AddProduct extends AdminProductEvent {
  final Product product;
  const AddProduct(this.product);
  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends AdminProductEvent {
  final Product product;
  const UpdateProduct(this.product);
  @override
  List<Object?> get props => [product];
}

class DeleteProduct extends AdminProductEvent {
  final String productId;
  const DeleteProduct(this.productId);
  @override
  List<Object?> get props => [productId];
}
