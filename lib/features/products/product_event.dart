part of 'product_bloc.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();
  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {}

class SearchProducts extends ProductEvent {
  final String query;
  const SearchProducts(this.query);
  @override
  List<Object?> get props => [query];
}

class FilterProductsByCategory extends ProductEvent {
  final String category;
  const FilterProductsByCategory(this.category);
  @override
  List<Object?> get props => [category];
}
