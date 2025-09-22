import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'product_bloc.dart';
import '../../models/product_model.dart';
import '../../widgets/dhamaka_offer_banner.dart';
import '../../models/carousel_image_model.dart';
import '../../models/offer_model.dart';
import '../../models/customer_review_model.dart';
import '../admin/carousel_repository.dart';
import '../admin/offer_repository.dart';
import '../admin/review_repository.dart';
import 'package:go_router/go_router.dart';
import 'product_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../cart/cart_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/login_dialog.dart';
import '../../widgets/profile_dialog.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final PageController _pageController = PageController();
  List<CarouselImage> _carouselImages = [];
  List<Offer> _offers = [];
  List<CustomerReview> _reviews = [];

  @override
  void initState() {
    super.initState();
    _loadCarouselImages();
    _loadOffers();
    _loadReviews();
    context.read<ProductBloc>().add(LoadProducts());
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadCarouselImages() async {
    try {
      final images = await CarouselRepository().fetchActiveCarouselImages();
      setState(() {
        _carouselImages = images;
      });
    } catch (e) {
      print('Error loading carousel images: $e');
    }
  }

  Future<void> _loadOffers() async {
    try {
      final offers = await OfferRepository().fetchActiveOffers();
      setState(() {
        _offers = offers;
      });
    } catch (e) {
      print('Error loading offers: $e');
    }
  }

  Future<void> _loadReviews() async {
    try {
      final reviews = await ReviewRepository().fetchActiveReviews();
      setState(() {
        _reviews = reviews;
      });
    } catch (e) {
      print('Error loading reviews: $e');
    }
  }

  void _onCarouselPageChanged(int index, CarouselPageChangedReason reason) {
    // Carousel page changed - can be used for indicators if needed
  }

  // Updated categories for Premium, Luxury, Arabic perfumes
  final List<Map<String, String>> categories = [
    {'icon': '👑', 'label': 'Premium Perfumes'},
    {'icon': '💎', 'label': 'Luxury Perfumes'},
    {'icon': '🏺', 'label': 'Arabic Perfumes'},
    {'icon': '🌸', 'label': 'For Women'},
    {'icon': '🕴️', 'label': 'For Men'},
    {'icon': '⚧️', 'label': 'Gender Neutral'},
  ];

  String? selectedCategory; // Track selected category

  final List<Map<String, String>> brandValues = [
    {'icon': '🌱', 'label': 'Cruelty Free'},
    {'icon': '💰', 'label': 'Affordable Luxury'},
    {'icon': '🌸', 'label': 'Fragrance Forward'},
    {'icon': '⚧️', 'label': 'Gender Neutral'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF), // Off-white theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1B33), // Midnight navy
        elevation: 0,
        title: LayoutBuilder(
          builder: (context, constraints) {
            final isMobile = constraints.maxWidth < 600;
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/logo.png', height: isMobile ? 32 : 46),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'UKInternational',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 18,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
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
                    icon: const Icon(
                      Icons.shopping_cart_outlined,
                      color: Colors.white,
                    ),
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
          IconButton(
            icon: const Icon(Icons.favorite_border, color: Colors.white),
            onPressed: () => context.push('/wishlist'),
          ),
          IconButton(
            icon: const Icon(Icons.person_outline, color: Colors.white),
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
          // Admin Login Button
          IconButton(
            icon: const Icon(Icons.admin_panel_settings, color: Colors.white),
            onPressed: () => context.push('/admin-login'),
            tooltip: 'Admin Login',
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1000;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
          final isMobile = constraints.maxWidth < 600;

          final contentPadding = isDesktop
              ? 120.0
              : isTablet
              ? 32.0
              : 16.0;
          final gridCrossAxisCount = isDesktop
              ? 4
              : isTablet
              ? 2 // Reduced from 3 to 2 for wider tiles
              : 1; // Reduced from 2 to 1 for mobile to make tiles much wider

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Hero Banner - Full Width
                if (_carouselImages.isNotEmpty)
                  CarouselSlider(
                    options: CarouselOptions(
                      height: isDesktop
                          ? 500
                          : isTablet
                          ? 400
                          : 250,
                      autoPlay: true,
                      enlargeCenterPage: false,
                      viewportFraction: 1.0,
                      aspectRatio: 16 / 9,
                      onPageChanged: _onCarouselPageChanged,
                    ),
                    items: _carouselImages
                        .map(
                          (image) => Container(
                            width: double.infinity,
                            child: Image.network(
                              image.imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, size: 50),
                                  ),
                            ),
                          ),
                        )
                        .toList(),
                  ),

                // Dhamaka Offer Banner - Animated
                DhamakaOfferBanner(isMobile: isMobile, isTablet: isTablet),

                // Content with padding
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: contentPadding,
                    vertical: 16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Categories - Commented out for now
                      // SizedBox(
                      //   height: isMobile ? 100 : 110,
                      //   child: ListView.separated(
                      //     scrollDirection: Axis.horizontal,
                      //     padding: const EdgeInsets.symmetric(horizontal: 8),
                      //     itemCount: categories.length,
                      //     separatorBuilder: (_, __) =>
                      //         SizedBox(width: isMobile ? 16 : 24),
                      //     itemBuilder: (context, i) => GestureDetector(
                      //       onTap: () =>
                      //           _onCategoryTap(categories[i]['label']!),
                      //       child: Container(
                      //         width: isMobile ? 80 : 90,
                      //         child: Column(
                      //           mainAxisSize: MainAxisSize.min,
                      //           children: [
                      //             CircleAvatar(
                      //               radius: isMobile ? 25 : 30,
                      //               backgroundColor:
                      //                   selectedCategory ==
                      //                       categories[i]['label']
                      //                   ? const Color(0xFF0C1B33)
                      //                   : const Color(0xFFECD9B0),
                      //               child: Text(
                      //                 categories[i]['icon']!,
                      //                 style: TextStyle(
                      //                   fontSize: isMobile ? 24 : 32,
                      //                 ),
                      //               ),
                      //             ),
                      //             const SizedBox(height: 8),
                      //             Flexible(
                      //               child: Text(
                      //                 categories[i]['label']!,
                      //                 style: TextStyle(
                      //                   fontSize: isMobile ? 11 : 14,
                      //                   fontWeight: FontWeight.w600,
                      //                   color:
                      //                       selectedCategory ==
                      //                           categories[i]['label']
                      //                       ? const Color(0xFF0C1B33)
                      //                       : Colors.black,
                      //                 ),
                      //                 textAlign: TextAlign.center,
                      //                 maxLines: 2,
                      //                 overflow: TextOverflow.ellipsis,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(height: 24),

                      // Offers - Fixed constraints
                      if (_offers.isNotEmpty) ...[
                        SizedBox(
                          height: isMobile ? 100 : 120,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            itemCount: _offers.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 16),
                            itemBuilder: (context, i) => ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: isDesktop
                                    ? 320
                                    : isTablet
                                    ? 260
                                    : 220,
                                minWidth: isDesktop
                                    ? 320
                                    : isTablet
                                    ? 260
                                    : 200,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0C1B33),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Flexible(
                                      child: Text(
                                        _offers[i].title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: isMobile ? 14 : 16,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Flexible(
                                      child: Text(
                                        _offers[i].description,
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: isMobile ? 11 : 13,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // Bestsellers with improved button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              'Bestsellers',
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: ElevatedButton.icon(
                              onPressed: () => context.push('/products'),
                              icon: Icon(
                                Icons.arrow_forward,
                                size: isMobile ? 16 : 18,
                              ),
                              label: Text(
                                isMobile ? 'Show All' : 'Show All Products',
                                style: TextStyle(fontSize: isMobile ? 12 : 14),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0C1B33),
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 12 : 20,
                                  vertical: isMobile ? 8 : 12,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Products Grid
                      BlocBuilder<ProductBloc, ProductState>(
                        builder: (context, state) {
                          if (state is ProductLoading) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          } else if (state is ProductLoaded) {
                            if (state.products.isEmpty) {
                              return const Center(
                                child: Text('No products found.'),
                              );
                            }

                            // Filter for bestsellers
                            final bestsellers = state.products
                                .where((product) => product.isTopSelling)
                                .take(4)
                                .toList();

                            final displayProducts = bestsellers.isEmpty
                                ? state.products.take(4).toList()
                                : bestsellers;

                            return GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: gridCrossAxisCount,
                                    childAspectRatio: isMobile
                                        ? 0.8
                                        : 0.7, // Increased from 0.65 to 0.8 for wider mobile tiles
                                    crossAxisSpacing: isMobile ? 12 : 16,
                                    mainAxisSpacing: isMobile ? 12 : 16,
                                  ),
                              itemCount: displayProducts.length,
                              itemBuilder: (context, index) {
                                final product = displayProducts[index];
                                return GestureDetector(
                                  onTap: () {
                                    context.push(
                                      '/product/${product.id}',
                                      extra: product,
                                    );
                                  },
                                  child: ProductCard(
                                    product: product,
                                    rating: 4.5,
                                  ),
                                );
                              },
                            );
                          } else if (state is ProductError) {
                            return Center(child: Text(state.message));
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 32),

                      // Product Categories Section
                      BlocBuilder<ProductBloc, ProductState>(
                        builder: (context, state) {
                          if (state is ProductLoaded) {
                            return _buildProductCategories(
                              state.products,
                              isMobile,
                              isTablet,
                              isDesktop,
                              gridCrossAxisCount,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      const SizedBox(height: 32),

                      // Customer Reviews - Fixed constraints
                      if (_reviews.isNotEmpty) ...[
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'What Our Customers Say',
                              style: TextStyle(
                                fontSize: isMobile ? 18 : 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              height: isMobile ? 180 : 220,
                              child: ListView.separated(
                                scrollDirection: Axis.horizontal,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                itemCount: _reviews.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 16),
                                itemBuilder: (context, i) => ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: isDesktop
                                        ? 340
                                        : isTablet
                                        ? 300
                                        : 280,
                                    minWidth: isDesktop
                                        ? 340
                                        : isTablet
                                        ? 300
                                        : 260,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.04),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            CircleAvatar(
                                              radius: isMobile ? 16 : 20,
                                              backgroundColor: const Color(
                                                0xFFA9744F,
                                              ),
                                              child: Text(
                                                _reviews[i].customerName[0],
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: isMobile ? 12 : 14,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    _reviews[i].customerName,
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      fontSize: isMobile
                                                          ? 12
                                                          : 14,
                                                    ),
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  const SizedBox(height: 4),
                                                  RatingBarIndicator(
                                                    rating: _reviews[i].rating,
                                                    itemBuilder: (context, _) =>
                                                        const Icon(
                                                          Icons.star,
                                                          color: Colors.amber,
                                                        ),
                                                    itemCount: 5,
                                                    itemSize: isMobile
                                                        ? 12.0
                                                        : 16.0,
                                                    direction: Axis.horizontal,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 8),
                                        Flexible(
                                          child: Text(
                                            _reviews[i].reviewText,
                                            style: TextStyle(
                                              fontSize: isMobile ? 10 : 12,
                                            ),
                                            maxLines: isMobile ? 2 : 3,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        // Show review image if available
                                        if (_reviews[i].imageUrl != null &&
                                            _reviews[i]
                                                .imageUrl!
                                                .isNotEmpty) ...[
                                          const SizedBox(height: 8),
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                            child: Image.network(
                                              _reviews[i].imageUrl!,
                                              height: isMobile ? 60 : 80,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (
                                                    context,
                                                    error,
                                                    stackTrace,
                                                  ) => Container(
                                                    height: isMobile ? 60 : 80,
                                                    width: double.infinity,
                                                    decoration: BoxDecoration(
                                                      color: Colors.grey[200],
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),
                                                    child: Icon(
                                                      Icons.image_not_supported,
                                                      size: isMobile ? 20 : 24,
                                                      color: Colors.grey[400],
                                                    ),
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                      ],

                      // Brand Values - Responsive layout
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return Wrap(
                              alignment: WrapAlignment.center,
                              spacing: isMobile ? 16 : 32,
                              runSpacing: 16,
                              children: brandValues
                                  .map(
                                    (val) => SizedBox(
                                      width: isMobile ? 80 : 100,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          CircleAvatar(
                                            radius: isMobile ? 20 : 25,
                                            backgroundColor: const Color(
                                              0xFFECD9B0,
                                            ),
                                            child: Text(
                                              val['icon']!,
                                              style: TextStyle(
                                                fontSize: isMobile ? 18 : 22,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            val['label']!,
                                            style: TextStyle(
                                              fontSize: isMobile ? 10 : 12,
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                  .toList(),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer - Full Width with responsive content
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: contentPadding,
                    vertical: 32,
                  ),
                  color: const Color(0xFF0C1B33),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/logo.png',
                            height: isMobile ? 24 : 32,
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              'UKInternational',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: isMobile ? 16 : 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        spacing: isMobile ? 16 : 24,
                        runSpacing: 8,
                        children: [
                          GestureDetector(
                            onTap: () => context.push('/about'),
                            child: Text(
                              'About Us',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: isMobile ? 12 : 14,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),
                          Text(
                            'Terms & Conditions',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                          Text(
                            'Privacy Policy',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                          Text(
                            'Contact Us',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                          Text(
                            'Support',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: _launchEmail,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.email, color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              'ukinternationalperfumes@gmail.com',
                              style: TextStyle(
                                color: Colors.white70,
                                decoration: TextDecoration.underline,
                                fontSize: isMobile ? 12 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _launchWhatsApp,
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Icon(Icons.phone, color: Colors.white70, size: 18),
                            const SizedBox(width: 8),
                            Text(
                              '+91 7600662616',
                              style: TextStyle(
                                color: Colors.white70,
                                decoration: TextDecoration.underline,
                                fontSize: isMobile ? 12 : 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: _launchInstagram,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white10,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: FaIcon(
                                FontAwesomeIcons.instagram,
                                color: Colors.white70,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '@_uk_international',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: isMobile ? 12 : 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        '© 2025, UKInternational. All rights reserved.',
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: isMobile ? 10 : 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Business contact methods
  void _launchWhatsApp() async {
    const url = 'https://wa.me/917600662616';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchInstagram() async {
    const url = 'https://instagram.com/_uk_international';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _launchEmail() async {
    const url = 'mailto:ukinternationalperfumes@gmail.com';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Widget _buildProductCategories(
    List<Product> products,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
    int gridCrossAxisCount,
  ) {
    final categories = [
      {
        'name': 'Premium Perfumes',
        'icon': '👑',
        'discount': '60',
        'products': products
            .where((p) => p.category == 'Premium Perfumes')
            .toList(),
      },
      {
        'name': 'Luxury Perfumes',
        'icon': '💎',
        'discount': '50',
        'products': products
            .where((p) => p.category == 'Luxury Perfumes')
            .toList(),
      },
      {
        'name': 'Arabic Perfumes',
        'icon': '🏺',
        'discount': '50',
        'products': products
            .where((p) => p.category == 'Arabic Perfumes')
            .toList(),
      },
    ];

    return Column(
      children: categories.map((category) {
        final categoryProducts = category['products'] as List<Product>;
        if (categoryProducts.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  category['icon'] as String,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    category['name'] as String,
                    style: TextStyle(
                      fontSize: isMobile ? 20 : 24,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0C1B33),
                    ),
                  ),
                ),
                // Small Dhamaka Offer between category name and View All
                _buildSmallDhamakaOffer(
                  category['discount'] as String,
                  isMobile,
                ),
                const SizedBox(width: 12),
                if (categoryProducts.length > 4)
                  TextButton(
                    onPressed: () => context.push('/products'),
                    child: Text(
                      'View All (${categoryProducts.length})',
                      style: const TextStyle(
                        color: Color(0xFF0C1B33),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: gridCrossAxisCount,
                childAspectRatio: isMobile
                    ? 0.8
                    : 0.7, // Increased from 0.65 to 0.8 for wider mobile tiles
                crossAxisSpacing: isMobile ? 12 : 16,
                mainAxisSpacing: isMobile ? 12 : 16,
              ),
              itemCount: categoryProducts.length > 4
                  ? 4
                  : categoryProducts.length,
              itemBuilder: (context, index) {
                final product = categoryProducts[index];
                return GestureDetector(
                  onTap: () {
                    context.push('/product/${product.id}', extra: product);
                  },
                  child: ProductCard(product: product, rating: 4.5),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        );
      }).toList(),
    );
  }

  Widget _buildSmallDhamakaOffer(String discount, bool isMobile) {
    return SizedBox(
      width: isMobile ? 80 : 100,
      height: isMobile ? 40 : 50,
      child: _SmallDhamakaOfferWidget(discount: discount, isMobile: isMobile),
    );
  }
}

class _SmallDhamakaOfferWidget extends StatefulWidget {
  final String discount;
  final bool isMobile;

  const _SmallDhamakaOfferWidget({
    required this.discount,
    required this.isMobile,
  });

  @override
  State<_SmallDhamakaOfferWidget> createState() =>
      _SmallDhamakaOfferWidgetState();
}

class _SmallDhamakaOfferWidgetState extends State<_SmallDhamakaOfferWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _burstController;
  late AnimationController _rotationController;
  late AnimationController _popperController;

  late Animation<double> _pulseAnimation;
  late Animation<double> _burstAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _popperAnimation;

  @override
  void initState() {
    super.initState();

    // Font pulsing animation (bigger to smaller)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseController.repeat(reverse: true);

    // Burst animation for explosion effects
    _burstController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _burstAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _burstController, curve: Curves.easeOut));
    _burstController.repeat();

    // Rotation animation for burst elements
    _rotationController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(parent: _rotationController, curve: Curves.linear),
    );
    _rotationController.repeat();

    // Party popper animation
    _popperController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _popperAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _popperController, curve: Curves.easeOut),
    );
    _popperController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _burstController.dispose();
    _rotationController.dispose();
    _popperController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      return AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _burstAnimation,
          _rotationAnimation,
          _popperAnimation,
        ]),
        builder: (context, child) {
          final rotationValue = _rotationAnimation.value;
          final burstValue = _burstAnimation.value;
          final popperValue = _popperAnimation.value;

          return CustomPaint(
            painter: _SmallDhamakaPainter(
              burstProgress: burstValue,
              rotation: rotationValue,
              popperProgress: popperValue,
              isMobile: widget.isMobile,
            ),
            child: Center(
              child: Transform.scale(
                scale: _pulseAnimation.value,
                child: Text(
                  '${widget.discount}% OFF',
                  style: TextStyle(
                    fontSize: widget.isMobile ? 10.0 : 12.0,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: 0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.3),
                        offset: const Offset(1, 1),
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      // Fallback to simple container if animation fails
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE53E3E), Color(0xFFC53030)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '${widget.discount}% OFF',
          style: TextStyle(
            fontSize: widget.isMobile ? 10.0 : 12.0,
            fontWeight: FontWeight.w900,
            color: Colors.white,
            letterSpacing: 0.5,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
  }
}

class _SmallDhamakaPainter extends CustomPainter {
  final double burstProgress;
  final double rotation;
  final double popperProgress;
  final bool isMobile;

  _SmallDhamakaPainter({
    required this.burstProgress,
    required this.rotation,
    required this.popperProgress,
    required this.isMobile,
  });

  @override
  void paint(Canvas canvas, Size size) {
    try {
      final center = Offset(size.width / 2, size.height / 2);
      final paint = Paint()..style = PaintingStyle.fill;

      // Draw starburst background
      _drawStarburst(canvas, center, size, paint, rotation, burstProgress);

      // Draw party popper effects
      _drawPartyPoppers(canvas, center, size, paint, rotation, popperProgress);

      // Draw sparkles
      _drawSparkles(canvas, center, size, paint, rotation, burstProgress);
    } catch (e) {
      // Fallback to simple red circle if custom painting fails
      final center = Offset(size.width / 2, size.height / 2);
      final paint = Paint()
        ..style = PaintingStyle.fill
        ..color = const Color(0xFFE53E3E);
      canvas.drawCircle(center, size.width * 0.4, paint);
    }
  }

  void _drawStarburst(
    Canvas canvas,
    Offset center,
    Size size,
    Paint paint,
    double rotationValue,
    double burstValue,
  ) {
    final path = Path();
    final baseRadius = size.width * 0.3;
    final spikeLength = size.width * 0.1;
    const int numSpikes = 6;

    // Create dynamic starburst shape with sharp, energetic edges
    for (int i = 0; i < numSpikes * 2; i++) {
      final double angle = (math.pi / numSpikes) * i + rotationValue * 0.5;
      final double radius = (i % 2 == 0)
          ? baseRadius
          : baseRadius + spikeLength * burstValue;
      final double x = center.dx + radius * math.cos(angle);
      final double y = center.dy + radius * math.sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Fill with red gradient
    final gradient = RadialGradient(
      colors: [
        const Color(0xFFE53E3E), // Red
        const Color(0xFFC53030), // Darker red
      ],
      stops: const [0.0, 1.0],
    );
    paint.shader = gradient.createShader(
      Rect.fromCircle(center: center, radius: size.width * 0.4),
    );
    canvas.drawPath(path, paint);

    // Add a subtle border
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 1.0;
    paint.color = Colors.red[900]!.withOpacity(0.8);
    canvas.drawPath(path, paint);
  }

  void _drawPartyPoppers(
    Canvas canvas,
    Offset center,
    Size size,
    Paint paint,
    double rotationValue,
    double popperValue,
  ) {
    paint.style = PaintingStyle.fill;

    // Draw multiple party popper particles - enhanced for small widget
    for (int i = 0; i < 16; i++) {
      // Increased from 8 to 16
      final angle = (i * 22.5 + rotationValue * 45) * math.pi / 180;
      final distance = 25.0 * popperValue; // Increased from 15 to 25
      final x = center.dx + math.cos(angle) * distance;
      final y = center.dy + math.sin(angle) * distance;

      // Colors matching the main banner - more colors
      final colors = [
        Colors.purple,
        Colors.pink,
        Colors.yellow,
        Colors.lightBlue,
        Colors.green,
        Colors.orange,
        Colors.red,
        Colors.blue,
        Colors.cyan,
        Colors.lime,
        Colors.indigo,
        Colors.teal,
      ];
      paint.color = colors[i % colors.length].withOpacity(0.9 * popperValue);

      // Draw circles of varying sizes - more variety
      final radius = (0.8 + (i % 3) * 0.4) * popperValue; // More size variation
      canvas.drawCircle(Offset(x, y), radius, paint);
    }

    // Add scattered confetti around the burst - increased area and count
    for (int i = 0; i < 8; i++) {
      // Increased from 4 to 8
      final randomX =
          center.dx +
          (math.sin(popperValue * 2 * math.pi + i) *
              size.width *
              0.4); // Increased area
      final randomY =
          center.dy +
          (math.cos(popperValue * 2 * math.pi + i) *
              size.height *
              0.4); // Increased area

      final colors = [
        Colors.purple,
        Colors.pink,
        Colors.yellow,
        Colors.lightBlue,
        Colors.cyan,
        Colors.lime,
      ];
      paint.color = colors[i % colors.length].withOpacity(0.8 * popperValue);
      canvas.drawCircle(
        Offset(randomX, randomY),
        (0.6 + (i % 2) * 0.3) * popperValue,
        paint,
      );
    }

    // Add extra burst particles for more pop in small widget
    for (int i = 0; i < 6; i++) {
      final burstAngle = (i * 60.0 + rotationValue * 60) * math.pi / 180;
      final burstDistance = 35.0 * popperValue; // Larger area for small widget
      final burstX = center.dx + math.cos(burstAngle) * burstDistance;
      final burstY = center.dy + math.sin(burstAngle) * burstDistance;

      final burstColors = [
        Colors.purple,
        Colors.pink,
        Colors.yellow,
        Colors.cyan,
      ];
      paint.color = burstColors[i % burstColors.length].withOpacity(
        0.7 * popperValue,
      );
      canvas.drawCircle(Offset(burstX, burstY), 1.2 * popperValue, paint);
    }
  }

  void _drawSparkles(
    Canvas canvas,
    Offset center,
    Size size,
    Paint paint,
    double rotationValue,
    double burstValue,
  ) {
    paint.style = PaintingStyle.fill;

    // Draw sparkles around the burst
    for (int i = 0; i < 4; i++) {
      final sparkleAngle = (i * 90.0 + rotationValue * 45) * math.pi / 180;
      final sparkleDistance = 15.0 * burstValue;
      final sparkleX = center.dx + math.cos(sparkleAngle) * sparkleDistance;
      final sparkleY = center.dy + math.sin(sparkleAngle) * sparkleDistance;

      paint.color = Colors.white.withOpacity(0.9 * burstValue);
      canvas.drawCircle(Offset(sparkleX, sparkleY), 1.5 * burstValue, paint);
    }

    // Draw central glow
    paint.color = Colors.yellow[300]!.withOpacity(0.7 * burstValue);
    canvas.drawCircle(center, 3.0 * burstValue, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
