import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'product_bloc.dart';
import 'product_repository.dart';
import '../../models/product_model.dart';
import 'package:go_router/go_router.dart';
import 'product_card.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({Key? key}) : super(key: key);

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Dummy data for categories, offers, reviews, and brand values
  final List<Map<String, String>> categories = [
    {'label': 'Luxury Perfumes', 'icon': '💎'},
    {'label': 'Skincare', 'icon': '🧴'},
    {'label': 'Bath & Body', 'icon': '🛁'},
    {'label': 'Gift Sets', 'icon': '🎁'},
    {'label': 'Cosmetics', 'icon': '💄'},
  ];

  final List<Map<String, String>> offers = [
    {'title': 'Buy Any 3 for ₹999', 'desc': 'Mix & match your favorites!'},
    {'title': '2 for ₹649', 'desc': 'Best combos for you.'},
    {'title': 'Self Care Kit', 'desc': '12 for ₹1298 only!'},
  ];

  final List<Map<String, dynamic>> reviews = [
    {
      'avatar': '',
      'name': 'Sanna Thakur',
      'review':
          'UKInternational has raised the bar for the perfume industry. Such good quality at very affordable price.',
      'rating': 4.5,
    },
    {
      'avatar': '',
      'name': 'Amit Sharma',
      'review': 'Amazing fragrances and fast delivery! Highly recommended.',
      'rating': 5.0,
    },
    {
      'avatar': '',
      'name': 'Priya Singh',
      'review': 'Loved the packaging and the scent lasts all day.',
      'rating': 4.0,
    },
  ];

  final List<Map<String, String>> brandValues = [
    {'icon': '🌱', 'label': 'Cruelty Free'},
    {'icon': '💰', 'label': 'Affordable Luxury'},
    {'icon': '🌸', 'label': 'Fragrance Forward'},
    {'icon': '⚧️', 'label': 'Gender Neutral'},
  ];

  // Add a list of carousel images (network URLs)
  final List<String> carouselImages = [
    'https://images.unsplash.com/photo-1517841905240-472988babdf9?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1506744038136-46273834b3fb?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1465101046530-73398c7f28ca?auto=format&fit=crop&w=800&q=80',
    'https://images.unsplash.com/photo-1519125323398-675f0ddb6308?auto=format&fit=crop&w=800&q=80',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF), // Off-white theme
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C1B33), // Midnight navy
        elevation: 0,
        title: Row(
          children: [
            Image.asset('assets/logo.png', height: 46),
            const SizedBox(width: 12),
            const Text(
              'UKInternational',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart_outlined),
            onPressed: () {},
          ),
          IconButton(icon: const Icon(Icons.person_outline), onPressed: () {}),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth >= 1000;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1000;
          final horizontalPadding = isDesktop
              ? 120.0
              : isTablet
              ? 32.0
              : 16.0;
          final gridCrossAxisCount = isDesktop
              ? 4
              : isTablet
              ? 3
              : 2;
          return SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: 0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Hero Banner
                  CarouselSlider(
                    options: CarouselOptions(
                      height: isDesktop
                          ? 340
                          : isTablet
                          ? 260
                          : 180,
                      autoPlay: true,
                      enlargeCenterPage: true,
                      viewportFraction: 0.9,
                      aspectRatio: 16 / 9,
                    ),
                    items: carouselImages
                        .map(
                          (url) => ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Image.network(
                              url,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 16),
                  // Categories
                  SizedBox(
                    height: 90,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, i) => Column(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: const Color(
                              0xFFECD9B0,
                            ), // Classic cream
                            child: Text(
                              categories[i]['icon']!,
                              style: const TextStyle(fontSize: 28),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            categories[i]['label']!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Offers
                  SizedBox(
                    height: 120,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: offers.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, i) => Container(
                        width: isDesktop
                            ? 320
                            : isTablet
                            ? 260
                            : 220,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0C1B33),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              offers[i]['title']!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              offers[i]['desc']!,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Bestsellers
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Bestsellers',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          context.push('/products');
                        },
                        child: const Text('View All'),
                      ),
                    ],
                  ),
                  BlocBuilder<ProductBloc, ProductState>(
                    builder: (context, state) {
                      if (state is ProductLoading) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (state is ProductLoaded) {
                        if (state.products.isEmpty) {
                          return const Center(
                            child: Text('No products found.'),
                          );
                        }
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: gridCrossAxisCount,
                                childAspectRatio: 0.7,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                              ),
                          itemCount: state.products.length > 4
                              ? 4
                              : state.products.length,
                          itemBuilder: (context, index) {
                            final product = state.products[index];
                            return GestureDetector(
                              onTap: () {
                                context.push(
                                  '/product/${product.id}',
                                  extra: product,
                                );
                              },
                              child: ProductCard(product: product, rating: 4.5),
                            );
                          },
                        );
                      } else if (state is ProductError) {
                        return Center(child: Text(state.message));
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                  const SizedBox(height: 24),
                  // Customer Reviews
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'What Our Customers Say',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 140,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: reviews.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, i) => Container(
                            width: isDesktop
                                ? 340
                                : isTablet
                                ? 300
                                : 260,
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
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFA9744F),
                                  child: Text(
                                    reviews[i]['name']![0],
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        reviews[i]['name']!,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        child: Text(
                                          reviews[i]['review']!,
                                          style: const TextStyle(fontSize: 12),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      RatingBarIndicator(
                                        rating: reviews[i]['rating'] ?? 4.5,
                                        itemBuilder: (context, _) => const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                        ),
                                        itemCount: 5,
                                        itemSize: 16.0,
                                        direction: Axis.horizontal,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Brand Values
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 32,
                      runSpacing: 16,
                      children: brandValues
                          .map(
                            (val) => Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  backgroundColor: const Color(0xFFECD9B0),
                                  child: Text(
                                    val['icon']!,
                                    style: const TextStyle(fontSize: 22),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  val['label']!,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          )
                          .toList(),
                    ),
                  ),
                  // Footer
                  Container(
                    margin: const EdgeInsets.only(top: 24),
                    padding: const EdgeInsets.all(24),
                    color: const Color(0xFF0C1B33),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Image.asset('assets/logo.png', height: 32),
                            const SizedBox(width: 10),
                            const Text(
                              'UKInternational',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 24,
                          runSpacing: 8,
                          children: [
                            Text(
                              'Terms & Conditions',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Privacy Policy',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Contact Us',
                              style: TextStyle(color: Colors.white70),
                            ),
                            Text(
                              'Support',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.email, color: Colors.white70, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'support@ukinternational.com',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone, color: Colors.white70, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              '+91 90000 00000',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(Icons.facebook, color: Colors.white70),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.link,
                              color: Colors.white70,
                            ), // TODO: Replace with Instagram icon
                            const SizedBox(width: 8),
                            Icon(
                              Icons.link,
                              color: Colors.white70,
                            ), // TODO: Replace with Twitter icon
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '© 2025, UKInternational. All rights reserved.',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
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

class ProductDetailsScreen extends StatelessWidget {
  final Product product;
  const ProductDetailsScreen({required this.product, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(product.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                product.imageUrl,
                height: 200,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.name,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(product.description),
            const SizedBox(height: 16),
            Row(
              children: [
                Text(
                  '₹${product.mrp.toStringAsFixed(2)}',
                  style: const TextStyle(
                    decoration: TextDecoration.lineThrough,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '₹${product.priceAfterOffer.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '${product.offer.toStringAsFixed(0)}% OFF',
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Wishlist'),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.shopping_cart),
                  label: const Text('Add to Cart'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
