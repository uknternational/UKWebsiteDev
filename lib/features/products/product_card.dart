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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                    Text(
                      product.name,
                      style: TextStyle(
                        fontSize: isSmall ? 12 : 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: isSmall ? 1 : 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: isSmall ? 2 : 4),
                    RatingBarIndicator(
                      rating: rating,
                      itemBuilder: (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: isSmall ? 12.0 : 16.0,
                      direction: Axis.horizontal,
                    ),
                    SizedBox(height: isSmall ? 2 : 4),
                    // Responsive price section
                    if (isSmall) ...[
                      // Stack prices vertically for very small cards
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '₹${product.mrp.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                    decorationThickness: 1.5,
                                    color: Colors.grey[500],
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  borderRadius: BorderRadius.circular(3),
                                ),
                                child: Text(
                                  '${product.offer.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.w700,
                                    fontSize: 10,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '₹${product.priceAfterOffer.toStringAsFixed(0)}',
                            style: const TextStyle(
                              color: Color(0xFF0C1B33),
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ] else ...[
                      // Horizontal layout for larger cards
                      Row(
                        children: [
                          Flexible(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (product.offer > 0)
                                  Text(
                                    '₹${product.mrp.toStringAsFixed(0)}',
                                    style: TextStyle(
                                      decoration: TextDecoration.lineThrough,
                                      decorationThickness: 2,
                                      color: Colors.grey[500],
                                      fontSize: isMobile ? 12 : 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                Text(
                                  '₹${product.priceAfterOffer.toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: const Color(0xFF0C1B33),
                                    fontWeight: FontWeight.w700,
                                    fontSize: isMobile ? 16 : 18,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (product.offer > 0) ...[
                            const SizedBox(width: 4),
                            Flexible(
                              flex: 1,
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: isMobile ? 4 : 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${product.offer.toStringAsFixed(0)}% OFF',
                                  style: TextStyle(
                                    color: Colors.red[700],
                                    fontWeight: FontWeight.w700,
                                    fontSize: isMobile ? 10 : 12,
                                    letterSpacing: 0.2,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
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
