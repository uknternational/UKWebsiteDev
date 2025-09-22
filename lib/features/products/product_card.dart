import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final double rating;
  const ProductCard({required this.product, this.rating = 4.5, Key? key})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 200;
        final isSmall = constraints.maxWidth < 160;

        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Image.network(
                    product.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.image_not_supported),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(isSmall ? 6.0 : 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product name and stars in same row
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            product.name,
                            style: TextStyle(
                              fontSize: isSmall ? 18 : 21, // 1.5x larger
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        RatingBarIndicator(
                          rating: rating,
                          itemBuilder: (context, _) =>
                              const Icon(Icons.star, color: Colors.amber),
                          itemCount: 5,
                          itemSize: isSmall ? 18.0 : 24.0, // 1.5x larger
                          direction: Axis.horizontal,
                        ),
                      ],
                    ),
                    SizedBox(height: isSmall ? 2 : 4),
                    // Responsive price section
                    if (isSmall) ...[
                      // Stack prices vertically for very small cards - improved layout
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Prices in same row
                          Row(
                            children: [
                              Text(
                                '₹${product.mrp.toStringAsFixed(0)}',
                                style: TextStyle(
                                  decoration: TextDecoration.lineThrough,
                                  decorationThickness: 2.25, // 1.5x larger
                                  color: Colors.grey[500],
                                  fontSize: 16.5, // 1.5x larger
                                  fontWeight: FontWeight.w700, // Made bold
                                ),
                              ),
                              const SizedBox(
                                width: 6,
                              ), // Add spacing between prices
                              Text(
                                '₹${product.priceAfterOffer.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Color(0xFF0C1B33),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22.5, // 1.5x larger
                                  letterSpacing: 0.45, // 1.5x larger
                                ),
                              ),
                            ],
                          ),
                          // Discount badge in separate row below
                          const SizedBox(
                            height: 4,
                          ), // Add spacing between price row and discount
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6, // Increased padding
                              vertical: 3, // Increased padding
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red[100],
                              borderRadius: BorderRadius.circular(
                                4,
                              ), // Slightly more rounded
                            ),
                            child: Text(
                              '${product.offer.toStringAsFixed(0)}% OFF',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.w700,
                                fontSize: 11, // Slightly smaller for better fit
                                letterSpacing: 0.3, // 1.5x larger
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Horizontal layout for larger cards - improved layout
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Prices in same row
                          Row(
                            children: [
                              if (product.offer > 0) ...[
                                Text(
                                  '₹${product.mrp.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    decorationThickness: 3, // 1.5x larger
                                    color: Colors.grey[500],
                                    fontSize: isMobile ? 18 : 21, // 1.5x larger
                                    fontWeight: FontWeight.w700, // Made bold
                                  ),
                                ),
                                const SizedBox(
                                  width: 8,
                                ), // Add spacing between prices
                              ],
                              Text(
                                '₹${product.priceAfterOffer.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: const Color(0xFF0C1B33),
                                  fontWeight: FontWeight.w700,
                                  fontSize: isMobile ? 24 : 27, // 1.5x larger
                                  letterSpacing: 0.75, // 1.5x larger
                                ),
                              ),
                            ],
                          ),
                          // Discount badge in separate row below
                          if (product.offer > 0) ...[
                            const SizedBox(
                              height: 6,
                            ), // Add spacing between price row and discount
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isMobile
                                    ? 8
                                    : 10, // Increased padding
                                vertical: isMobile ? 4 : 6, // Increased padding
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red[100],
                                borderRadius: BorderRadius.circular(
                                  6,
                                ), // Slightly more rounded
                              ),
                              child: Text(
                                '${product.offer.toStringAsFixed(0)}% OFF',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontWeight: FontWeight.w700,
                                  fontSize: isMobile
                                      ? 12
                                      : 14, // Slightly smaller for better fit
                                  letterSpacing: 0.3, // 1.5x larger
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
