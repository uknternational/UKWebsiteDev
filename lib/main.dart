import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'services/supabase_service.dart';
import 'core/constants/app_constants.dart';
import 'core/config/environment.dart';
import 'features/products/product_list_screen.dart'
    show ProductListScreen, ProductDetailsScreen;
import 'models/product_model.dart';
import 'features/products/product_bloc.dart';
import 'features/products/product_repository.dart';
import 'features/admin/admin_login_screen.dart';
import 'features/admin/admin_auth_bloc.dart';
import 'features/admin/admin_auth_repository.dart';
import 'features/admin/admin_dashboard_screen.dart';
import 'features/products/product_card.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  EnvironmentConfig.initialize(Environment.staging); // Set to staging

  // Initialize Supabase
  await SupabaseService().init();

  runApp(const MyApp());
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: AppConstants.homeRoute,
      builder: (context, state) => const ProductListScreen(),
    ),
    GoRoute(
      path: AppConstants.adminRoute,
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const AdminDashboardScreen(),
      redirect: (context, state) {
        final authBloc = BlocProvider.of<AdminAuthBloc>(context, listen: false);
        final isAuthenticated = authBloc.repository.currentUser != null;
        if (!isAuthenticated) {
          return AppConstants.adminRoute;
        }
        return null;
      },
    ),
    GoRoute(
      path: '/products',
      builder: (context, state) => const _AllProductsScreen(),
    ),
    GoRoute(
      path: '/product/:id',
      builder: (context, state) {
        final product = state.extra as Product?;
        if (product != null) {
          return ProductDetailsScreen(product: product);
        } else {
          return const Scaffold(
            body: Center(child: Text('Product not found.')),
          );
        }
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ProductBloc(ProductRepository())),
        BlocProvider(create: (_) => AdminAuthBloc(AdminAuthRepository())),
      ],
      child: MaterialApp.router(
        title: 'UK International Perfumes',
        theme: AppTheme.lightTheme,
        routerConfig: _router,
        builder: (context, child) {
          return Banner(
            location: BannerLocation.topEnd,
            message: EnvironmentConfig.current.environmentName,
            color: EnvironmentConfig.current.environmentName == 'Production'
                ? Colors.green
                : Colors.orange,
            child: child!,
          );
        },
      ),
    );
  }
}

class _AllProductsScreen extends StatefulWidget {
  const _AllProductsScreen({Key? key}) : super(key: key);

  @override
  State<_AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<_AllProductsScreen> {
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    // Ensure products are loaded
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.trim();
    if (query.isEmpty) {
      context.read<ProductBloc>().add(LoadProducts());
    } else {
      context.read<ProductBloc>().add(SearchProducts(query));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('All Products')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1000;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
          final gridCrossAxisCount = isDesktop
              ? 4
              : isTablet
              ? 3
              : 2;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search products...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (_) => _onSearchChanged(),
                ),
              ),
              Expanded(
                child: BlocBuilder<ProductBloc, ProductState>(
                  builder: (context, state) {
                    if (state is ProductLoading) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (state is ProductLoaded) {
                      if (state.products.isEmpty) {
                        return const Center(child: Text('No products found.'));
                      }
                      return GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: gridCrossAxisCount,
                          childAspectRatio: 0.7,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                        ),
                        itemCount: state.products.length,
                        itemBuilder: (context, index) {
                          final product = state.products[index];
                          return GestureDetector(
                            onTap: () {
                              context.push(
                                '/product/${product.id}',
                                extra: product,
                              );
                            },
                            child: ProductCard(product: product),
                          );
                        },
                      );
                    } else if (state is ProductError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
