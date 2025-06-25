import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'services/supabase_service.dart';
import 'services/auth_service.dart';
import 'services/wishlist_service.dart';
import 'core/constants/app_constants.dart';
import 'core/config/environment.dart';
import 'features/products/product_list_screen.dart' show ProductListScreen;
import 'features/cart/cart_screen.dart';
import 'features/cart/cart_service.dart';
import 'widgets/login_dialog.dart';
import 'widgets/profile_dialog.dart';
import 'models/product_model.dart';
import 'features/products/product_bloc.dart';
import 'features/products/product_repository.dart';
import 'features/admin/admin_login_screen.dart';
import 'features/admin/admin_auth_bloc.dart';
import 'features/admin/admin_auth_repository.dart';
import 'features/admin/enhanced_admin_dashboard.dart';
import 'features/products/product_card.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize environment configuration
  EnvironmentConfig.initialize(Environment.staging); // Use staging database

  // Initialize Supabase
  await SupabaseService().init();

  runApp(const MyApp());
}

final _router = GoRouter(
  redirect: (context, state) {
    // Check if trying to access admin dashboard without authentication
    if (state.matchedLocation == '/admin/dashboard') {
      final authBloc = BlocProvider.of<AdminAuthBloc>(context, listen: false);
      final isAuthenticated = authBloc.repository.currentUser != null;
      if (!isAuthenticated) {
        return '/admin-login';
      }
    }
    return null;
  },
  routes: [
    GoRoute(
      path: AppConstants.homeRoute,
      builder: (context, state) => const ProductListScreen(),
    ),
    GoRoute(
      path: '/admin-login',
      builder: (context, state) => const AdminLoginScreen(),
    ),
    GoRoute(
      path: '/admin/dashboard',
      builder: (context, state) => const EnhancedAdminDashboard(),
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
    GoRoute(path: '/cart', builder: (context, state) => const CartScreen()),
    GoRoute(
      path: '/wishlist',
      builder: (context, state) => const WishlistScreen(),
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
        debugShowCheckedModeBanner: false,
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
      backgroundColor: const Color(0xFFF8F5EF),
      appBar: AppBar(
        title: const Text('All Products'),
        backgroundColor: const Color(0xFF0C1B33),
        foregroundColor: Colors.white,
        actions: [
          // Cart with badge
          StreamBuilder<int>(
            stream: Stream.periodic(
              const Duration(seconds: 1),
            ).asyncMap((_) => CartService.getCartItemCount()),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => context.push('/cart'),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          // Wishlist button
          IconButton(
            icon: const Icon(Icons.favorite),
            onPressed: () => context.push('/wishlist'),
          ),
          // Profile button
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () {
              if (AuthService().isLoggedIn) {
                showDialog(
                  context: context,
                  builder: (ctx) => const ProfileDialog(),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (ctx) => const LoginDialog(),
                );
              }
            },
          ),
        ],
      ),
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
                    filled: true,
                    fillColor: Colors.white,
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

class ProductDetailsScreen extends StatefulWidget {
  final Product product;
  const ProductDetailsScreen({required this.product, Key? key})
    : super(key: key);

  @override
  State<ProductDetailsScreen> createState() => _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends State<ProductDetailsScreen> {
  bool isInWishlist = false;

  @override
  void initState() {
    super.initState();
    _checkWishlistStatus();
  }

  Future<void> _checkWishlistStatus() async {
    if (AuthService().isLoggedIn) {
      final inWishlist = await WishlistService.isInWishlist(widget.product.id);
      setState(() {
        isInWishlist = inWishlist;
      });
    }
  }

  Future<void> _addToCart(BuildContext context) async {
    // Check if user is logged in
    if (!AuthService().isLoggedIn) {
      final success = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => LoginDialog(
          message: 'Please log in to add items to your cart',
          onSuccess: () async {
            // Migrate local cart to database after login
            await CartService.migratLocalCartToDatabase();
          },
        ),
      );

      if (success != true) return;
    }

    try {
      await CartService.addToCart(widget.product);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.product.name} added to cart!'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'View Cart',
            textColor: Colors.white,
            onPressed: () {
              context.push('/cart');
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding to cart: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleWishlist() async {
    if (!AuthService().isLoggedIn) {
      final success = await showDialog<bool>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LoginDialog(
          message: 'Please log in to add items to your wishlist',
        ),
      );

      if (success != true) return;
    }

    try {
      if (isInWishlist) {
        await WishlistService.removeFromWishlist(widget.product.id);
        setState(() {
          isInWishlist = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.product.name} removed from wishlist'),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        await WishlistService.addToWishlist(widget.product);
        setState(() {
          isInWishlist = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.product.name} added to wishlist!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      appBar: AppBar(
        title: Text(widget.product.name),
        backgroundColor: const Color(0xFF0C1B33),
        foregroundColor: Colors.white,
        actions: [
          // Cart with badge
          StreamBuilder<int>(
            stream: Stream.periodic(
              const Duration(seconds: 1),
            ).asyncMap((_) => CartService.getCartItemCount()),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => context.push('/cart'),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                constraints: const BoxConstraints(
                  maxHeight: 400,
                  maxWidth: 400,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    widget.product.imageUrl,
                    fit: BoxFit.contain,
                    width: double.infinity,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 300,
                      child: const Icon(Icons.image_not_supported, size: 100),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              widget.product.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0C1B33),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              widget.product.description,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[700],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Price Details',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (widget.product.offer > 0) ...[
                        Text(
                          '₹${widget.product.mrp.toStringAsFixed(2)}',
                          style: const TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],
                      Text(
                        '₹${widget.product.priceAfterOffer.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                          color: Color(0xFF0C1B33),
                        ),
                      ),
                      if (widget.product.offer > 0) ...[
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red[100],
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${widget.product.offer.toStringAsFixed(0)}% OFF',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (widget.product.offer > 0) ...[
                    const SizedBox(height: 8),
                    Text(
                      'You save ₹${(widget.product.mrp - widget.product.priceAfterOffer).toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _toggleWishlist,
                    icon: Icon(
                      isInWishlist ? Icons.favorite : Icons.favorite_border,
                    ),
                    label: Text(
                      isInWishlist ? 'Remove from Wishlist' : 'Add to Wishlist',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isInWishlist
                          ? Colors.red[50]
                          : Colors.white,
                      foregroundColor: isInWishlist
                          ? Colors.red
                          : const Color(0xFF0C1B33),
                      side: BorderSide(
                        color: isInWishlist
                            ? Colors.red
                            : const Color(0xFF0C1B33),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _addToCart(context),
                    icon: const Icon(Icons.shopping_cart),
                    label: const Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0C1B33),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.local_shipping, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Delivery Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text('• Free delivery on orders above ₹499'),
                  Text('• Standard delivery: 3-5 business days'),
                  Text('• Express delivery available'),
                  Text('• Cash on delivery available'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Updated Wishlist Screen
class WishlistScreen extends StatefulWidget {
  const WishlistScreen({Key? key}) : super(key: key);

  @override
  State<WishlistScreen> createState() => _WishlistScreenState();
}

class _WishlistScreenState extends State<WishlistScreen> {
  List<Product> wishlistItems = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWishlistItems();
  }

  Future<void> _loadWishlistItems() async {
    if (!AuthService().isLoggedIn) {
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      final items = await WishlistService.getWishlistItems();
      setState(() {
        wishlistItems = items;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _removeFromWishlist(String productId) async {
    try {
      await WishlistService.removeFromWishlist(productId);
      _loadWishlistItems();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Item removed from wishlist'),
          backgroundColor: Colors.orange,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!AuthService().isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFFF8F5EF),
        appBar: AppBar(
          title: const Text('Wishlist'),
          backgroundColor: const Color(0xFF0C1B33),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_border, size: 80, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Please log in to view your wishlist',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const LoginDialog(),
                  );
                },
                child: const Text('Log In'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0C1B33),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      appBar: AppBar(
        title: const Text('Wishlist'),
        backgroundColor: const Color(0xFF0C1B33),
        foregroundColor: Colors.white,
        actions: [
          StreamBuilder<int>(
            stream: Stream.periodic(
              const Duration(seconds: 1),
            ).asyncMap((_) => CartService.getCartItemCount()),
            builder: (context, snapshot) {
              final count = snapshot.data ?? 0;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart),
                    onPressed: () => context.push('/cart'),
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : wishlistItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Your wishlist is empty',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Add some products to your wishlist',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final product = wishlistItems[index];
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            product.imageUrl,
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey[200],
                                  child: const Icon(Icons.image_not_supported),
                                ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                product.description,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  if (product.offer > 0) ...[
                                    Text(
                                      '₹${product.mrp.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        decoration: TextDecoration.lineThrough,
                                        color: Colors.grey,
                                        fontSize: 12,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                  ],
                                  Text(
                                    '₹${product.priceAfterOffer.toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: Color(0xFF0C1B33),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            IconButton(
                              onPressed: () => _removeFromWishlist(product.id),
                              icon: const Icon(Icons.delete, color: Colors.red),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                context.push(
                                  '/product/${product.id}',
                                  extra: product,
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0C1B33),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              child: const Text(
                                'View',
                                style: TextStyle(fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
